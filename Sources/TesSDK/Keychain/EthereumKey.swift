//
//  Ethereum.swift
//  TesSDK
//
//  Created by Yehor Popovych on 2/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import Web3
import CryptoSwift

// "44'/60'/index'/0/0"
struct EthereumKeyPath: KeyPath {
    let account: UInt32
    
    var change: UInt32 { return 0 }
    var address: UInt32 { return 0 }
    var purpose: UInt32 { return BIP44_KEY_PATH_PURPOSE } // BIP44
    var coin: UInt32 { return Network.Ethereum.nId } // ETH Coin Type
}

struct EthereumHDWalletKeyFactory: HDWalletKeyFactory {
    let network: Network = .Ethereum
    
    func keyDataFrom(seed: Data) throws -> Data {
        let bytesHash = SHA3(variant: .keccak256).calculate(for: seed.bytes)
        return Data(bytes: try EthereumPrivateKey(privateKey: bytesHash).rawPrivateKey)
    }
    
    func from(data: Data) throws -> HDWalletKey {
        return try EthereumHDWalletKey(data: data)
    }
}

//TODO: Refactor to proper HDWallet
struct EthereumHDWalletKey: HDWalletKey {
    private let pk: EthereumPrivateKey
    
    init(data: Data) throws {
        pk = try EthereumPrivateKey(bytes: data)
    }
    
    func pubKey(path: KeyPath) throws -> Data {
        return Data(bytes: try _pKey(for: path).publicKey.rawPublicKey)
    }
    
    func privateKey(keyPath: KeyPath) throws -> Data {
        return Data(bytes: try _pKey(for: keyPath).rawPrivateKey)
    }
    
    func address(path: KeyPath) throws -> String {
        return try _pKey(for: path).address.hex(eip55: false)
    }
    
    func sign(data: Data, path: KeyPath) throws -> Data {
        let signature = try _pKey(for: path).sign(message: data.bytes)
        var signData = Data(bytes: signature.r)
        signData.append(Data(bytes: signature.s))
        signData.append(UInt8(signature.v + 27))
        return data
    }
    
    func verify(data: Data, signature: Data, path: KeyPath) throws -> Bool {
        let ourPubKey = try _pKey(for: path).publicKey
        let r = try EthereumQuantity(bytes: data.subdata(in: 0..<32))
        let s = try EthereumQuantity(bytes: data.subdata(in: 32..<64))
        let v = EthereumQuantity(integerLiteral: UInt64(data[64] - 27))
        let dataPubKey = try EthereumPublicKey(message: data.bytes, v: v, r: r, s: s)
        return ourPubKey == dataPubKey
    }
    
    private func _pKey(for path: KeyPath) throws -> EthereumPrivateKey {
        guard path.address == 0 && path.change == 0 && path.coin == Network.Ethereum.nId && path.purpose == 0x8000002C else {
            throw HDWalletError.wrongKeyPath
        }
        return pk
    }
}
