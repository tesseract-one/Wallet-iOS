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

extension OpenWalletRequestDataProtocol {
    public var type : String {
        return Self.type
    }
}

public class OpenWalletResponse<Response: Codable> {
    public struct Data<R: Codable>: Codable {
        let version: OpenWalletVersion
        let id: UInt32
        let response: R
    }
    
    private let data: Data<Response>
    
    public init(data: Data<Response>) {
        self.data = data
    }
    
    public convenience init(json: String) throws {
        let data = try JSONDecoder().decode(Data<Response>.self, from: json.data(using: .utf8)!)
        self.init(data: data)
    }
    
    public init(id: UInt32, response: Response) {
        data = Data(version: .v1, id: id, response: response)
    }
    
    public func serialize() throws -> String {
        let bytes = try JSONEncoder().encode(data)
        return String(data: bytes, encoding: .utf8)!
    }
}

public class OpenWalletRequest<Request: OpenWalletRequestDataProtocol>: NSObject, UIActivityItemSource {
    public struct Data<R: Codable>: Codable {
        let version: OpenWalletVersion
        let id: UInt32
        let request: R
    }
    
    public let data: Data<Request>
    
    public init(data: Data<Request>) {
        self.data = data
    }
    
    public init(id: UInt32, request: Request) {
        data = Data(version: .v1, id: id, request: request)
    }
    
    public convenience init(json: String) throws {
        let data = try JSONDecoder().decode(Data<Request>.self, from: json.data(using: .utf8)!)
        self.init(data: data)
    }
    
    public func serialize() throws -> String {
        let bytes = try JSONEncoder().encode(data)
        return String(data: bytes, encoding: .utf8)!
    }
    
    public func response(data: Request.Response) -> OpenWalletResponse<Request.Response> {
        return OpenWalletResponse(id: self.data.id, response: data)
    }
    
    open func activityType() -> UIActivity.ActivityType {
        return UIActivity.ActivityType(rawValue: "org.openwallet")
    }
    
    open func dataTypeUTI() -> String {
        return "org.openwallet"
    }
    
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        switch activityType {
        case self.activityType():
            return try? serialize()
        default:
            return nil
        }
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        switch activityType {
        case self.activityType():
            return dataTypeUTI()
        default:
            return ""
        }
    }
}
