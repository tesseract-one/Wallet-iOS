//
//  OpenWalletHandler.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/7/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import PromiseKit

private struct OpenWalletBaseMessageData: OpenWalletRequestDataProtocol {
    typealias Response = String
    static var type: String = "__base" // Not used
    
    let type: String
}

public protocol OpenWalletRequestHandler {
    var supportedUTI: Array<String> { get }
    
    typealias Completion = (Error?, OpenWalletResponseProtocol?) -> Void
    func viewContoller(for type: String, request: String, uti: String, cb: @escaping Completion) throws -> UIViewController
}

open class OpenWalletExtensionViewController: UIViewController {
    open var handlers: Array<OpenWalletRequestHandler> {
        return []
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        let itemOpt = extensionContext!.inputItems
            .compactMap{$0 as? NSExtensionItem}
            .compactMap{$0.attachments}
            .flatMap{$0}
            .first
        
        guard let item = itemOpt else {
            extensionContext!.cancelRequest(withError: OpenWalletError.emptyRequest)
            return
        }
        
        guard let requestUTI = item.registeredTypeIdentifiers.first else {
            extensionContext!.cancelRequest(withError: OpenWalletError.emptyRequest)
            return
        }
        
        let handlerOpt = handlers.first{$0.supportedUTI.contains(requestUTI)}
        
        guard let handler = handlerOpt else {
            extensionContext!.cancelRequest(withError: OpenWalletError.cantHandleAPI(requestUTI))
            return
        }
        
        item.loadItem(forTypeIdentifier: requestUTI, options: nil) { [unowned self] request, error in
            guard let dataStr = request as? String, let base = try? OpenWalletRequest<OpenWalletBaseMessageData>(json: dataStr, uti: requestUTI) else {
                self.extensionContext!.cancelRequest(withError: OpenWalletError.wrongRequest(item))
                return
            }
            DispatchQueue.main.async {
                do {
                    let vc = try handler.viewContoller(for: base.data.request.type, request: dataStr, uti: requestUTI) { err, res in
                        if let err = err {
                            self.extensionContext!.cancelRequest(withError: err)
                        } else if let res = res {
                            do {
                                let reply = NSExtensionItem()
                                reply.attachments = [
                                    NSItemProvider(item: try res.serialize() as NSSecureCoding, typeIdentifier: res.uti)
                                ]
                                self.extensionContext!.completeRequest(returningItems: [reply], completionHandler: nil)
                            } catch (let err) {
                                self.extensionContext!.cancelRequest(withError: err)
                            }
                        } else {
                            self.extensionContext!.cancelRequest(withError: OpenWalletError.emptyResponse)
                        }
                    }
                    self.showViewController(vc: vc)
                } catch(let err) {
                    self.extensionContext!.cancelRequest(withError: err)
                }
            }
        }
    }
    
    open func cancelRequest() {
        self.extensionContext!.cancelRequest(withError: OpenWalletError.cancelled)
    }
    
    open func showViewController(vc: UIViewController) {
        for view in view.subviews {
            view.removeFromSuperview()
        }
        view.addSubview(vc.view)
        for child in children {
            child.removeFromParent()
        }
        addChild(vc)
    }
}
