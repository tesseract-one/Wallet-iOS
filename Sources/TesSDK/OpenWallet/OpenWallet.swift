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
    case cantHandleAPI(String)
    case emptyRequest
    case emptyResponse
    case decodeError(Error)
    case wrongResponse(Any?)
    case wrongRequest(Any?)
}

public class OpenWallet: SignProvider {
    private let window: UIWindow
    private var requestCounter: UInt32
    private let lock = NSLock()
    private var requestQueue: Array<UIActivityViewController> = []
    
    public static var networkUTIs: Dictionary<Network, String> = [
        .Ethereum: "ethereum"
    ]
    
    public var networks: Set<Network> {
        return Set(OpenWallet.networkUTIs.keys)
    }
    
    public init(window: UIWindow) {
        // TODO: Remove this
        self.window = window
        self.requestCounter = 0
    }
    
    private static func response<R: OpenWalletRequestDataProtocol>(req: OpenWalletRequest<R>, items: [Any]?) -> Promise<R.Response> {
        return Promise { resolver in
            let attachments = items?.compactMap {$0 as? NSExtensionItem}.compactMap{$0.attachments}.flatMap{$0}
            guard let item = attachments?.first else {
                resolver.reject(OpenWalletError.emptyResponse)
                return
            }
            item.loadItem(forTypeIdentifier: req.uti, options: nil) { result, error in
                if let error = error {
                    resolver.reject(error)
                } else if let data = result as? String {
                    do {
                        resolver.fulfill(try req.parseResponse(json: data).data.response)
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
        return Promise<R.Response> { resolver in
            let vc = UIActivityViewController(activityItems: [request], applicationActivities: nil)
            
            // All system types
            vc.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .copyToPasteboard,
                                        .copyToPasteboard, .mail, .markupAsPDF, .message, .openInIBooks,
                                        .postToFacebook, .postToFlickr, .postToTencentWeibo, .postToTwitter,
                                        .postToVimeo, .postToWeibo, .print, .saveToCameraRoll]
            
            vc.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                defer {
                    DispatchQueue.main.async {
                        self.requestQueue.removeFirst()
                        guard let rootView = self.window.rootViewController else {
                            return
                        }
                        if self.requestQueue.count > 0 {
                            rootView.present(self.requestQueue[0], animated: true, completion: nil)
                        }
                    }
                }
                if let error = error {
                    resolver.reject(error)
                    return
                }
                guard completed else {
                    resolver.reject(OpenWalletError.cancelled)
                    return
                }
                OpenWallet
                    .response(req: request, items: returnedItems)
                    .done { resolver.fulfill($0) }
                    .catch { resolver.reject($0) }
            }
            
            DispatchQueue.main.async {
                guard let rootView = self.window.rootViewController else {
                    return resolver.reject(OpenWalletError.emptyRootView)
                }
                self.requestQueue.append(vc)
                
                if self.requestQueue.count == 1 {
                    rootView.present(vc, animated: true, completion: nil)
                }
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
