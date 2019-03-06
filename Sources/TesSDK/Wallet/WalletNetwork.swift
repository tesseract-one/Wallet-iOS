//
//  WalletNetwork.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/6/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

public protocol WalletNetworkSupportFactory {
    var network: Network { get }
    
    func withHdWallet(wallet: HDWallet) -> WalletNetworkSupport
}

public protocol WalletNetworkSupport {
    func createFirstAddress(accountIndex: UInt32) throws -> Address
}
