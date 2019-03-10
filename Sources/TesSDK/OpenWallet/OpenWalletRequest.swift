//
//  OpenWalletRequest.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/7/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

public enum OpenWalletVersion: String, Codable {
    case v1 = "1.0"
}

public protocol OpenWalletRequestDataProtocol: Codable {
    associatedtype Response: Codable
    
    static var type: String { get }
    
    var type: String { get }
}

public protocol OpenWalletSerializableProtocol {
    var uti: String { get }
    
    init(json: String, uti: String) throws
    
    func serialize() throws -> String
}

public protocol OpenWalletResponseProtocol: OpenWalletSerializableProtocol {}

public struct OpenWalletResponse<Request: OpenWalletRequestDataProtocol>: OpenWalletResponseProtocol {
    public struct Data<R: Codable>: Codable {
        let version: OpenWalletVersion
        let id: UInt32
        let response: R
    }
    
    public let data: Data<Request.Response>
    public let uti: String
    
    public init(data: Data<Request.Response>, uti: String) {
        self.data = data
        self.uti = uti
    }
    
    public init(json: String, uti: String) throws {
        self.data = try JSONDecoder().decode(Data<Request.Response>.self, from: json.data(using: .utf8)!)
        self.uti = uti
    }
    
    public init(id: UInt32, response: Request.Response, uti: String) {
        self.data = Data(version: .v1, id: id, response: response)
        self.uti = uti
    }
    
    public func serialize() throws -> String {
        let bytes = try JSONEncoder().encode(data)
        return String(data: bytes, encoding: .utf8)!
    }
}

public class OpenWalletRequest<Request: OpenWalletRequestDataProtocol>: NSObject, UIActivityItemSource, OpenWalletSerializableProtocol {
    public struct Data<R: Codable>: Codable {
        let version: OpenWalletVersion
        let id: UInt32
        let request: R
    }
    
    public let data: Data<Request>
    public let uti: String
    
    public init(data: Data<Request>, uti: String) {
        self.data = data
        self.uti = uti
    }
    
    public init(id: UInt32, request: Request, uti: String) {
        data = Data(version: .v1, id: id, request: request)
        self.uti = uti
    }
    
    required public init(json: String, uti: String) throws {
        self.data = try JSONDecoder().decode(Data<Request>.self, from: json.data(using: .utf8)!)
        self.uti = uti
    }
    
    public func serialize() throws -> String {
        let bytes = try JSONEncoder().encode(data)
        return String(data: bytes, encoding: .utf8)!
    }
    
    public func response(data: Request.Response) -> OpenWalletResponse<Request> {
        return OpenWalletResponse(id: self.data.id, response: data, uti: uti)
    }
    
    public func parseResponse(json: String) throws -> OpenWalletResponse<Request> {
        return try OpenWalletResponse<Request>(json: json, uti: uti)
    }
    
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return try? serialize()
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return uti
    }
}
