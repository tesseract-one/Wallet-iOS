//
//  NewWalletData.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

public struct NewWalletData {
    private let keys: Dictionary<Network, Data>
    
    public let mnemonic: String
    public let name: String
    
    internal init(name: String, mnemonic: String, keys: Dictionary<Network, Data>) {
        self.mnemonic = mnemonic
        self.keys = keys
        self.name = name
    }
    
    internal var walletData: WalletDataV1 {
        return WalletDataV1(keys: keys)
    }
}
