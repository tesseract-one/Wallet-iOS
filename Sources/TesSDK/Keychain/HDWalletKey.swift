//
//  KeyGenerator.swift
//  TesSDK
//
//  Created by Yehor Popovych on 2/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

public protocol KeyPath {
    var purpose: UInt32 { get }
    var coin: UInt32 { get }
    var account: UInt32 { get }
    var change: UInt32 { get }
    var address: UInt32 { get }
}

public let BIP44_KEY_PATH_PURPOSE: UInt32 = 0x8000002C

public protocol HDWalletKeyFactory {
    var network: Network { get }
    
    func keyDataFrom(seed: Data) throws -> Data
    func from(data: Data) throws -> HDWalletKey
}

public protocol HDWalletKey {
    func pubKey(path: KeyPath) throws -> Data
    func address(path: KeyPath) throws -> String
    func sign(data: Data, path: KeyPath) throws -> Data
    func verify(data: Data, signature: Data, path: KeyPath) throws -> Bool
    
    //TODO: Remove this SHIT!!!!
    func privateKey(keyPath: KeyPath) throws -> Data
}
