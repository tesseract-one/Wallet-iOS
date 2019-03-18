//
//  Serialization.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

public protocol SerializableProtocol: Codable {
    init(_ serializable: SerializableValue) throws
    var serializable: SerializableValue { get }
}

extension SerializableProtocol {
    public init?(_ serializable: SerializableValue) {
        do {
            try self.init(serializable)
        } catch {
            return nil
        }
    }
}

public enum SerializableValue: SerializableProtocol {
    case null
    case bool(Bool)
    case int(Int)
    case float(Double)
    case data(Data)
    case date(Date)
    case string(String)
    case array(Array<SerializableValue>)
    case object(SerializableObject)
    
    public init(_ serializable: SerializableValue) {
        self = serializable
    }
    
    public init(from value: SerializableProtocol) {
        self = value.serializable
    }
    
    public var serializable: SerializableValue {
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
        } else if let float = try? container.decode(Double.self) {
            self = .float(float)
        } else if let date = try? container.decode(Date.self) {
            self = .date(date)
        } else if let data = try? container.decode(Data.self) {
            self = .data(data)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([SerializableValue].self) {
            self = .array(array)
        } else if let object = try? container.decode(SerializableObject.self) {
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
        case .float(let num): try container.encode(num)
        case .data(let data): try container.encode(data)
        case .date(let date): try container.encode(date)
        case .string(let str): try container.encode(str)
        case .array(let arr): try container.encode(arr)
        case .object(let obj): try container.encode(obj)
        }
    }
    
    public enum Error: Swift.Error {
        case notInitializable(SerializableValue)
    }
}

public struct SerializableObject: SerializableProtocol {
    public var data: Dictionary<String, SerializableValue>
    
    public subscript(key: String) -> SerializableProtocol? {
        get {
            return data[key]
        }
        set(newValue) {
            data[key] = newValue?.serializable
        }
    }
    
    public init(_ data: Dictionary<String, SerializableProtocol> = [:]) {
        self.data = data.mapValues { $0.serializable }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CustomCodingKeys.self)
        var data = Dictionary<String, SerializableValue>()
        for key in container.allKeys {
            data[key.stringValue] = try container.decode(SerializableValue.self, forKey: key)
        }
        self.data = data
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CustomCodingKeys.self)
        for (key, val) in data {
            try container.encode(val, forKey: CustomCodingKeys(stringValue: key)!)
        }
    }
    
    public init(_ serializable: SerializableValue) throws {
        guard case .object(let obj) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = obj
    }
    
    public var serializable: SerializableValue {
        return .object(self)
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

extension Int: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        guard case .int(let int) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = int
    }
    public var serializable: SerializableValue { return .int(self) }
}
extension SerializableProtocol {
    public var int: Int? {
        switch self {
        case let val as SerializableValue:
            guard case .int(let int) = val else { return nil }
            return int
        case let int as Int: return int
        default: return nil
        }
    }
}

extension Double: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        guard case .float(let num) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = num
    }
    public var serializable: SerializableValue { return .float(self) }
}
extension SerializableProtocol {
    public var float: Double? {
        switch self {
        case let val as SerializableValue:
            guard case .float(let num) = val else { return nil }
            return num
        case let num as Double: return num
        default: return nil
        }
    }
}

extension Bool: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        guard case .bool(let bool) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = bool
    }
    public var serializable: SerializableValue { return .bool(self) }
}
extension SerializableProtocol {
    public var bool: Bool? {
        switch self {
        case let val as SerializableValue:
            guard case .bool(let bool) = val else { return nil }
            return bool
        case let bool as Bool: return bool
        default: return nil
        }
    }
}

extension Date: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        guard case .date(let date) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = date
    }
    public var serializable: SerializableValue { return .date(self) }
}
extension SerializableProtocol {
    public var date: Date? {
        switch self {
        case let val as SerializableValue:
            guard case .date(let date) = val else { return nil }
            return date
        case let date as Date: return date
        default: return nil
        }
    }
}

extension Data: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        guard case .data(let data) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = data
    }
    public var serializable: SerializableValue { return .data(self) }
}
extension SerializableProtocol {
    public var data: Data? {
        switch self {
        case let val as SerializableValue:
            guard case .data(let data) = val else { return nil }
            return data
        case let data as Data: return data
        default: return nil
        }
    }
}

extension String: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        guard case .string(let str) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = str
    }
    public var serializable: SerializableValue { return .string(self) }
}
extension SerializableProtocol {
    public var string: String? {
        switch self {
        case let val as SerializableValue:
            guard case .string(let str) = val else { return nil }
            return str
        case let str as String: return str
        default: return nil
        }
    }
}

extension Array: SerializableProtocol where Element: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        guard case .array(let array) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = try array.map{ try Element($0) }
    }
    public var serializable: SerializableValue { return .array(self.map{$0.serializable}) }
}
extension SerializableProtocol {
    public var array: Array<SerializableValue>? {
        switch self {
        case let val as SerializableValue:
            guard case .array(let array) = val else { return nil }
            return array
        case let array as Array<SerializableValue>: return array
        case let array as Array<SerializableProtocol>: return array.map{$0.serializable}
        default: return nil
        }
    }
}

extension Dictionary: SerializableProtocol where Key == String, Value: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        guard case .object(let obj) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        try self.init(obj)
    }
    public init(_ object: SerializableObject) throws {
        self = try object.data.mapValues { try Value($0) }
    }
    public var serializable: SerializableValue {
        return .object(asObject)
    }
    public var asObject: SerializableObject {
        return SerializableObject(self)
    }
}
extension SerializableProtocol {
    public var object: SerializableObject? {
        switch self {
        case let val as SerializableValue:
            guard case .object(let obj) = val else { return nil }
            return obj
        case let object as SerializableObject: return object
        case let dict as Dictionary<String, SerializableProtocol>: return SerializableObject(dict)
        default: return nil
        }
    }
}

extension Dictionary where Value == SerializableValue {
    public subscript(key: Key) -> SerializableProtocol? {
        get {
            return self[key]
        }
        set(newValue) {
            self[key] = newValue?.serializable
        }
    }
}

extension Optional: SerializableProtocol where Wrapped: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        switch serializable {
        case .null: self = .none
        default: self = try .some(Wrapped(serializable))
        }
    }
    public var serializable: SerializableValue {
        switch self {
        case .none: return .null
        case .some(let val): return val.serializable
        }
    }
}
