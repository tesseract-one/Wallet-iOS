//
//  Wallet.swift
//  TesSDK
//
//  Created by Yehor Popovych on 2/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit
import CKMnemonic


public class Keychain {
    
    enum Error: Swift.Error {
        case networkIsNotSupported(Network)
        case wrongKeyPath
        case dataError
        case keyGenerationError
        case signatureError
        case mnemonicError
        case internalError
        case wrongPassword
    }
    
    private let keys: Dictionary<Network, KeychainKey>
    
    public static let factories: Dictionary<Network, KeychainKeyFactory> = [
        .Ethereum: EthereumKeychainKeyFactory()
    ]
    
    public var networks: Set<Network> {
        return Set(Keychain.factories.keys).intersection(keys.keys)
    }
    
    public static func generateMnemonic() throws -> String {
         return try CKMnemonic.generateMnemonic(strength: 128, language: .english)
    }
    
    public convenience init(encrypted: Data, password: String) throws {
        let decrypted: Data
        do {
            decrypted = try decrypt(data: encrypted, password: password)
        } catch CryptError.decryptionFailed {
            throw Error.wrongPassword
        }
        try self.init(data: WalletVersionedData.from(data: decrypted).walletData())
    }
    
    private convenience init(data: WalletDataV1) throws {
        try self.init(pkeys: data.keys)
    }
    
    private init(pkeys: Dictionary<Network, Data>) throws {
        let keysArr: Array<(Network, KeychainKey)> = try pkeys
            .compactMap {
                if let fact = Keychain.factories[$0.key] {
                    return ($0.key, try fact.from(data: $0.value))
                }
                return nil
        }
        self.keys = Dictionary(uniqueKeysWithValues: keysArr)
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
    
    private func _pk(net: Network) throws -> KeychainKey {
        if let pk = keys[net] {
            return pk
        }
        throw Error.networkIsNotSupported(net)
    }
    
    public static func fromSeed(seed: Data, password: String) throws -> (keychain: Keychain, encrypted: Data) {
        let keysTuple = try Keychain.factories.map { net, fact in
            return (net, try fact.keyDataFrom(seed: seed))
        }
        let keys = Dictionary(uniqueKeysWithValues: keysTuple)
        let keychain = try Keychain(pkeys: keys)
        let walletData = try WalletVersionedData(v1: WalletDataV1(keys: keys))
        let data = try encrypt(data: walletData.toData(), password: password)
        return (keychain, data)
    }
    
    public static func fromMnemonic(mnemonic: String, password: String) throws -> (keychain: Keychain, encrypted: Data) {
        let seedStr = try CKMnemonic.deterministicSeedString(from: mnemonic, passphrase: "", language: .english)
        guard seedStr != "" else { throw Error.mnemonicError }
        return try fromSeed(seed: seedStr.ck_mnemonicData(), password: password)
    }
    
    public static func changePassword(encrypted: Data, oldPassword: String, newPassword: String) throws -> Data {
        let data = try decrypt(data: encrypted, password: oldPassword)
        return try encrypt(data: data, password: newPassword)
    }
}
