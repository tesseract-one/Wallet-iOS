//
//  JSON.swift
//  Browser
//
//  Created by Yehor Popovych on 3/17/19.
//  Copyright © 2019 Daniel Leping. All rights reserved.
//

import Foundation

public protocol JsonValueEncodable {
    func encode() -> JsonValue
}

extension JsonValueEncodable {
    var jsv: JsonValue {
        return encode()
    }
}

public protocol JsonValueDecodable {
    init?(value: JsonValue)
}

public struct JsonObject: Codable, JsonValueEncodable, JsonValueDecodable {
    private var data: Dictionary<String, JsonValue>
    
    public init(_ data: Dictionary<String, JsonValue> = [:]) {
        self.data = data
    }
    
    public init(_ data: Dictionary<String, JsonValueEncodable>) {
        self.data = data.mapValues { $0.encode() }
    }
    
    public init?(value: JsonValue) {
        guard case .object(let obj) = value else { return nil }
        self = obj
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CustomCodingKeys.self)
        var data = Dictionary<String, JsonValue>()
        for key in container.allKeys {
            data[key.stringValue] = try container.decode(JsonValue.self, forKey: key)
        }
        self.data = data
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CustomCodingKeys.self)
        for (key, val) in data {
            try container.encode(val, forKey: CustomCodingKeys(stringValue: key)!)
        }
    }
    
    public func encode() -> JsonValue {
        return .object(self)
    }
    
    public subscript(key: String) -> JsonValueEncodable? {
        get {
            return data[key]
        }
        set(newValue) {
            data[key] = newValue?.encode()
        }
    }
    
    public var jsonData: Data {
        return try! JSONEncoder().encode(self)
    }
}


public enum JsonValue: Codable, JsonValueDecodable, JsonValueEncodable {
    case null
    case int(Int)
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([JsonValue])
    case object(JsonObject)
    
    public init?(value: JsonValue) {
        self = value
    }
    
    public func encode() -> JsonValue {
        return self
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JsonValue].self) {
            self = .array(array)
        } else if let object = try? container.decode(JsonObject.self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown value type")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .null: try container.encodeNil()
        case .bool(let bool): try container.encode(bool)
        case .int(let int): try container.encode(int)
        case .number(let num): try container.encode(num)
        case .string(let str): try container.encode(str)
        case .array(let arr): try container.encode(arr)
        case .object(let obj): try container.encode(obj)
        }
    }
    
    public var jsonData: Data {
        switch self {
        case .null: return "null".data(using: .utf8)!
        case .bool(let bool): return (bool ? "true" : "false").data(using: .utf8)!
        case .int(let int): return "\(int)".data(using: .utf8)!
        case .number(let num): return "\(num)".data(using: .utf8)!
        case .string(let str): return "\"\(str)\"".data(using: .utf8)!
        default:
            return try! JSONEncoder().encode(self)
        }
    }
}

extension Int: JsonValueEncodable {
    public func encode() -> JsonValue {
        return .int(self)
    }
}
extension Int: JsonValueDecodable {
    public init?(value: JsonValue) {
        guard case .int(let int) = value else { return nil }
        self = int
    }
}
extension Double: JsonValueEncodable {
    public func encode() -> JsonValue {
        return .number(self)
    }
}
extension Double: JsonValueDecodable {
    public init?(value: JsonValue) {
        guard case .number(let num) = value else { return nil }
        self = num
    }
}
extension String: JsonValueEncodable {
    public func encode() -> JsonValue {
        return .string(self)
    }
}
extension String: JsonValueDecodable {
    public init?(value: JsonValue) {
        guard case .string(let str) = value else { return nil }
        self = str
    }
}
extension Bool: JsonValueEncodable {
    public func encode() -> JsonValue {
        return .bool(self)
    }
}
extension Bool: JsonValueDecodable {
    public init?(value: JsonValue) {
        guard case .bool(let bool) = value else { return nil }
        self = bool
    }
}
extension Array: JsonValueEncodable where Element: JsonValueEncodable {
    public func encode() -> JsonValue {
        return .array(self.map { $0.encode() })
    }
}
extension Dictionary: JsonValueEncodable where Key == String, Value: JsonValueEncodable {
    public func encode() -> JsonValue {
        return .object(JsonObject(self))
    }
}
extension Optional: JsonValueEncodable where Wrapped: JsonValueEncodable {
    public func encode() -> JsonValue {
        switch self {
        case .none:
            return .null
        case .some(let wrpd):
            return wrpd.encode()
        }
    }
}
extension Optional: JsonValueDecodable where Wrapped: JsonValueDecodable {
    public init?(value: JsonValue) {
        if case .null = value {
            self = .none
            return
        }
        guard let val = Wrapped(value: value) else {
            return nil
        }
        self = .some(val)
    }
}

private struct CustomCodingKeys: CodingKey {
    let stringValue: String
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int? { return nil }
    init?(intValue: Int) { return nil }
}
