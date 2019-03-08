//
//  OpenWallet.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/6/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit
import Darwin

enum OpenWalletError: Error {
    case emptyRootView
    case cancelled
    case wrongActivityType(UIActivity.ActivityType?)
    case cantHandleAPI(String)
    case emptyRequest
    case emptyResponse
    case decodeError(Error)
    case wrongResponse(Any?)
    case wrongRequest(Any?)
}

public class OpenWallet: SignProvider {
    private let appDelegate: UIApplicationDelegate
    
    private var requestCounter: UInt32
    private let lock = NSLock()
    
    public let networks: Set<Network> = Set([.Ethereum])
    
    public init(appDelegate: UIApplicationDelegate) {
        self.appDelegate = appDelegate
        self.requestCounter = 0
    }
    
    private static func response<R: OpenWalletRequestDataProtocol>(req: OpenWalletRequest<R>, items: [Any]?) -> Promise<R.Response> {
        return Promise { resolver in
            let attachments = items?.compactMap {$0 as? NSExtensionItem}.compactMap{$0.attachments}.flatMap{$0}
            guard let item = attachments?.first else {
                resolver.reject(OpenWalletError.emptyResponse)
                return
            }
            item.loadItem(forTypeIdentifier: req.dataTypeUTI(), options: nil) { result, error in
                if let error = error {
                    resolver.reject(error)
                } else if let result = result as? [String], let string = result.first, let data = string.data(using: .utf8) {
                    do {
                        resolver.fulfill(try JSONDecoder().decode(R.Response.self, from: data))
                    } catch(let err) {
                        resolver.reject(OpenWalletError.decodeError(err))
                    }
                } else {
                    resolver.reject(OpenWalletError.wrongResponse(result))
                }
            }
        }
    }
    
    public func request<R: OpenWalletRequestDataProtocol>(_ request: OpenWalletRequest<R>) -> Promise<R.Response> {
        return Promise<R.Response> { [weak self] resolver in
            let vc = UIActivityViewController(activityItems: [request], applicationActivities: nil)
            
            // All system types
            vc.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .copyToPasteboard,
                                        .copyToPasteboard, .mail, .markupAsPDF, .message, .openInIBooks,
                                        .postToFacebook, .postToFlickr, .postToTencentWeibo, .postToTwitter,
                                        .postToVimeo, .postToWeibo, .print, .saveToCameraRoll]
            
            vc.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                if let error = error {
                    resolver.reject(error)
                    return
                }
                guard completed else {
                    resolver.reject(OpenWalletError.cancelled)
                    return
                }
                if activityType != request.activityType() {
                    resolver.reject(OpenWalletError.wrongActivityType(activityType))
                    return
                }
                OpenWallet
                    .response(req: request, items: returnedItems)
                    .done { resolver.fulfill($0) }
                    .catch { resolver.reject($0) }
            }
            
            guard let window = self?.appDelegate.window, let rootView = window?.rootViewController else {
                return resolver.reject(OpenWalletError.emptyRootView)
            }
            
            DispatchQueue.main.async {
                rootView.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    public var requestId: UInt32 {
        lock.lock()
        requestCounter += 1
        defer { lock.unlock() }
        return requestCounter
    }
}

extension OpenWallet {
    public var distributedAPI: dAPI {
        let dapi = dAPI()
        dapi.signProvider = self
        return dapi
    }
}
