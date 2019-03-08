//
//  MainViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 2/25/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK

let walletService = WalletService()

class MainViewController: OpenWalletExtensionViewController {
    @IBOutlet weak var containerView: UIView!
    
    override var handlers: Array<OpenWalletRequestHandler> {
        return [
            OpenWalletEthereumKeychainRequestHandler(viewProvider: EthereumKeychainViewProvider())
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        walletService.bootstrap()
    }
    
    @IBAction func cancel() {
        self.cancelRequest()
    }
    
    override func showViewController(vc: UIViewController) {
        for view in containerView.subviews {
            view.removeFromSuperview()
        }
        containerView.addSubview(vc.view)
        for child in children {
            child.removeFromParent()
        }
        addChild(vc)
    }
}
