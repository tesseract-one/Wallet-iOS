//
//  WalletNotInitializedViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 4/2/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import OpenWallet


class WalletNotInitializedViewController: ExtensionWalletNotInitializedViewController {
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var desctiptionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var desctiptionLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var desctiptionRightConstraint: NSLayoutConstraint!
    
    override var walletUrlScheme: String {
        return "tesseract-one://"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIScreen.main.bounds.width > 320 {
            headerTopConstraint.constant = 44
            desctiptionBottomConstraint.constant = 64
            desctiptionLeftConstraint.constant = 34
            desctiptionRightConstraint.constant = 34
        } else {
            headerTopConstraint.constant = 24
            desctiptionBottomConstraint.constant = 32
            desctiptionLeftConstraint.constant = 16
            desctiptionRightConstraint.constant = 16
        }
    }
}
