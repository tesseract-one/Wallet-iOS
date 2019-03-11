//
//  MainViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 2/25/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK
import Material

class MainViewController: OpenWalletExtensionViewController {
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    let context = ExtensionContext()
    
    override var handlers: Array<OpenWalletRequestHandler> {
        return [
            OpenWalletEthereumKeychainRequestHandler(viewProvider: EthereumKeychainViewProvider())
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context.errors
            .observeIn(.immediateOnMain)
            .with(weak: self)
            .observeNext { err, sself in
                sself.extensionContext!.cancelRequest(withError: err)
            }.dispose(in: reactive.bag)
        
        context.bootstrap()
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
        containerView.layout(vc.view).edges()
        
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
