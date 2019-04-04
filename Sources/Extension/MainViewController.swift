//
//  MainViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 2/25/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import SnapKit
import OpenWallet

class MainViewController: OpenWallet.ExtensionViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    let context = ExtensionContext()
    
    override var handlers: Array<RequestHandler> {
        return [
            EthereumKeychainRequestHandler(viewProvider: EthereumKeychainViewProvider())
        ]
    }
    
    private func handleRequest(data: String, uti: String) {
        super.onLoaded(data: data, uti: uti)
    }
    
    override func onLoaded(data: String, uti: String) {
        context.errors
            .observeIn(.immediateOnMain)
            .with(weak: self)
            .observeNext { err, sself in
                sself.error(.unknownError(err))
            }.dispose(in: reactive.bag)
        
        context
            .walletIsLoaded
            .observeIn(.immediateOnMain)
            .with(weak: self)
            .observeNext { hasWallet, sself in
                if hasWallet {
                    sself.handleRequest(data: data, uti: uti)
                } else {
                    sself.walletIsNotInitialized()
                }
            }
            .dispose(in: reactive.bag)
        
        context.bootstrap()
    }
    
    override func walletIsNotInitialized() {
        super.walletIsNotInitialized()
        
        headerView.isHidden = true
        headerHeightConstraint.constant = 0
    }
    
    override func walletNotInitializedController() -> ExtensionWalletNotInitializedViewController {
        return self.storyboard!.instantiateViewController(withIdentifier: "WalletIsNotInitialized")
        as! WalletNotInitializedViewController
    }
    
    @IBAction func cancel() {
        self.cancelRequest()
    }
    
    override func showViewController(vc: UIViewController) {
        for view in containerView.subviews {
            view.removeFromSuperview()
        }
        
        if let contexted = vc as? ExtensionViewController {
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
        if let extVc = vc as? ExtensionViewController {
            subTitleLabel.text = extVc.subTitle
        } else {
            subTitleLabel.text = nil
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
