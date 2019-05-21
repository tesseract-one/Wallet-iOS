//
//  URLHandlerMainViewController.swift
//  Tesseract
//
//  Created by Yehor Popovych on 5/22/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class URLHandlerMainViewController: OpenWalletMainViewController {
    
    override func walletIsNotInitialized() {
        error(.walletIsNotInitialized)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

extension URLHandlerMainViewController: ContextSubject {
    
    func apply(context: RouterContextProtocol) {
        self.context = context.get(context: ApplicationContext.self)!
    }
}
