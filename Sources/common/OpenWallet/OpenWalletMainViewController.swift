//
//  OpenWalletMainViewController.swift
//  Tesseract
//
//  Created by Yehor Popovych on 5/21/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import SnapKit
import OpenWallet


class OpenWalletMainViewController: ExtensionViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    public var context: CommonContext!
    
    override func initialize() {
        super.initialize()
        handlers = [
            EthereumKeychainRequestHandler(viewProvider: EthereumKeychainViewProvider())
        ]
    }
    
    private func handleRequest(handler: RequestHandler, json: String, uti: String) {
        super.onLoaded(handler: handler, json: json, uti: uti)
    }
    
    override func onLoaded(handler: RequestHandler, json: String, uti: String) {
        context!
            .errorNode
            .delay(interval: 0.5)
            .observeIn(.immediateOnMain)
            .with(weak: self)
            .observeNext { err, sself in
                if let error = err as? OpenWalletError {
                    sself.error(error)
                } else {
                    sself.error(.unknownError(err))
                }
            }.dispose(in: reactive.bag)
        
        context!
            .isApplicationLoaded
            .filter { $0 }
            .with(latestFrom: context.wallet)
            .map { $1 != nil }
            .observeIn(.immediateOnMain)
            .with(weak: self)
            .observeNext { hasWallet, sself in
                if hasWallet {
                    sself.handleRequest(handler: handler, json: json, uti: uti)
                } else {
                    sself.walletIsNotInitialized()
                }
            }
            .dispose(in: reactive.bag)
    }
    
    @IBAction func cancel() {
        self.cancelRequest()
    }
    
    override func showViewController(vc: UIViewController) {
        for view in containerView.subviews {
            view.removeFromSuperview()
        }
        
        if let contexted = vc as? OpenWalletViewController {
            contexted.context = context
        }
        
        containerView.addSubview(vc.view)
        
        vc.view.snp.makeConstraints { v in
            v.edges.equalToSuperview()
        }
        
        for child in children {
            child.removeFromParent()
        }
        addChild(vc)
        
        titleLabel.text = vc.title
        if let extVc = vc as? OpenWalletViewController {
            subTitleLabel.text = extVc.subTitle
        } else {
            subTitleLabel.text = nil
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
