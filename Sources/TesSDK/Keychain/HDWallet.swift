//
//  Wallet.swift
//  TesSDK
//
//  Created by Yehor Popovych on 2/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit
import Mnemonic

enum HDWalletError: Error {
    case networkIsNotSupported(Network)
    case wrongKeyPath
    case dataError
    case keyGenerationError
}

class HDWallet {
    let name: String
    
    private let keys: Dictionary<Network, HDWalletKey>
    private let factories: Dictionary<Network, HDWalletKeyFactory>
    
    init(factories: Array<HDWalletKeyFactory>, name: String, pkeys: Dictionary<Network, Data>) throws {
        self.name = name
        var fMap: Dictionary<Network, HDWalletKeyFactory> = [:]
        for fact in factories {
            fMap[fact.network] = fact
        }
        self.factories = fMap
        
        let keysArr: Array<(Network, HDWalletKey)> = try pkeys
            .compactMap {
                if let fact = fMap[$0.key] {
                    return ($0.key, try fact.from(data: $0.value))
                }
                return nil
            }
        self.keys = Dictionary(uniqueKeysWithValues: keysArr)
    }
    
    convenience init(name: String, data: WalletDataV1, factories: Array<HDWalletKeyFactory>) throws {
        try self.init(factories: factories, name: name, pkeys: data.keys)
    }
    
    func address(network: Network, path: KeyPath) throws -> String {
        return try _pk(net: network).address(path: path)
    }
    
    func pubKey(network: Network, path: KeyPath) throws -> Data {
        return try _pk(net: network).pubKey(path: path)
    }
    
    func sign(network: Network, data: Data, path: KeyPath) throws -> Data {
        return try _pk(net: network).sign(data: data, path: path)
    }
    
    func verify(network: Network, data: Data, signature: Data, path: KeyPath) throws -> Bool {
        return try _pk(net: network).verify(data: data, signature: signature, path: path)
    }
    
    //TODO: Remove this SHIT!!!!
    func privateKey(network: Network, keyPath: KeyPath) throws -> Data {
        return try _pk(net: network).privateKey(keyPath: keyPath)
    }
    
    private func _pk(net: Network) throws -> HDWalletKey {
        if let pk = keys[net] {
            return pk
        }
        throw HDWalletError.networkIsNotSupported(net)
    }
    
    static func keysFromMnemonic(mnemonic: Mnemonic, factories: Array<HDWalletKeyFactory>) throws -> Dictionary<Network, Data> {
        let seed = try mnemonic.toSeed(passphrase: "").ck_mnemonicData()
        let keys = try factories.map { fact in
            return (fact.network, try fact.keyDataFrom(seed: seed))
        }
        return Dictionary(uniqueKeysWithValues: keys)
    }
}
