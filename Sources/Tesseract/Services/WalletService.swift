//
//  WalletService.swift
//  Tesseract
//
//  Created by Yehor Popovych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import TesSDK
import ReactiveKit
import PromiseKit

class WalletService {
    private let storage: StorageProtocol = UserDefaults.standard
    private static let WALLET_KEY = "WALLET"
    
    func loadWallet() -> Promise<Wallet?> {
        return Wallet.hasWallet(name: WalletService.WALLET_KEY, storage: storage)
            .then {
                $0 ? Wallet.loadWallet(name: WalletService.WALLET_KEY, storage: self.storage).map { $0 as Wallet? }
                    : Promise<Wallet?>.value(nil)
        }
    }
}
