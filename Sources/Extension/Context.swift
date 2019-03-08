//
//  Context.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import TesSDK
import ReactiveKit

enum ExtensionErrors: Error {
    case walletIsEmpty
}

class ExtensionContext {
    let walletService = WalletService()
    
    let errors = SafePublishSubject<AnyError>()
    
    func bootstrap() {
        walletService.bootstrap()
        
        walletService
            .loadWallet()
            .done { wallet in
                if wallet == nil {
                    throw ExtensionErrors.walletIsEmpty
                }
            }
            .signal
            .errorNode
            .bind(to: errors)
    }
}
