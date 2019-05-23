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

class MainViewController: OpenWalletMainViewController {
    
    override func initialize() {
        super.initialize()
        dataChannel = ExtensionViewContollerShareChannel()
        context = ExtensionContext()
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
    
    override func onLoaded(handler: RequestHandler, json: String, uti: String) {
        super.onLoaded(handler: handler, json: json, uti: uti)
        (context as! ExtensionContext).bootstrap()
    }
}
