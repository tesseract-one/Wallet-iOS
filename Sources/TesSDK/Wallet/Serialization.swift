//
//  Serialization.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

public protocol AnySerializable: Codable {
    static var serializableType: String { get }
    
    init?(_ serializable: AnySerializableObject)
    var serialized: AnySerializableObject { get }
}

extension AnySerializable {
    public init?(_ serializable: AnySerializableObject) {
        if serializable.type != Self.serializableType {
            return nil
        }
        self = serializable.payload as! Self
    }
    
    public var serialized: AnySerializableObject {
        return AnySerializableObject(self)
    }
}

public struct AnySerializableObject: Codable {
    let type: String
    let payload: AnySerializable
    
    private enum CodingKeys: String, CodingKey {
        case type
        case payload
    }
    
    private typealias AttachmentDecoder = (KeyedDecodingContainer<CodingKeys>) throws -> AnySerializable
    private typealias AttachmentEncoder = (AnySerializable, inout KeyedEncodingContainer<CodingKeys>) throws -> Void
    
    private static var decoders: [String: AttachmentDecoder] = [:]
    private static var encoders: [String: AttachmentEncoder] = [:]
    
    static func register<A: AnySerializable>(_ type: A.Type) {
        decoders[type.serializableType] = { container in
            try container.decode(A.self, forKey: .payload)
        }
        encoders[type.serializableType] = { payload, container in
            try container.encode(payload as! A, forKey: .payload)
        }
    }
    
    init<S: AnySerializable>(_ serializable: S) {
        type = S.serializableType
        payload = serializable
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        
        if let decode = AnySerializableObject.decoders[type] {
            payload = try decode(container)
        } else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Invalid attachment: \(type).")
            throw DecodingError.dataCorrupted(context)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        
        guard let encode = AnySerializableObject.encoders[type] else {
            let context = EncodingError.Context(codingPath: [], debugDescription: "Invalid attachment: \(type).")
            throw EncodingError.invalidValue(self, context)
        }
            
        try encode(payload, &container)
    }
}

extension AnySerializableObject {
    static func initialize() {
        self.register(Int.self)
        self.register(Double.self)
        self.register(String.self)
        self.register(Data.self)
        self.register(Dictionary<String, AnySerializableObject>.self)
        self.register(Array<AnySerializableObject>.self)
    }
}

extension Int: AnySerializable {
    public static let serializableType: String = "integer"
}

extension Double: AnySerializable {
    public static let serializableType: String = "double"
}

extension String: AnySerializable {
    public static let serializableType: String = "string"
}

extension Data: AnySerializable {
    public static let serializableType: String = "data"
}

extension Dictionary: AnySerializable where Key == String, Value == AnySerializableObject {
    public static let serializableType: String = "dictionary"
}

extension Array: AnySerializable where Element == AnySerializableObject {
    public static let serializableType: String = "array"
}
