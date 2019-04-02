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
    override var walletUrlScheme: String {
        return "tesseract://"
    }
}
