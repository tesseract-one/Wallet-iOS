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
import BigInt

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
        return EthereumHDNode(seed: seed)!.serialize()!
    }
    
    func from(data: Data) throws -> HDWalletKey {
        return try EthereumHDWalletKey(data: data)
    }
}

//TODO: Refactor to proper HDWallet
struct EthereumHDWalletKey: HDWalletKey {
    private let pk: EthereumHDNode
    
    init(data: Data) throws {
        let key =  EthereumHDNode(data)?
            .derive(index: BIP44_KEY_PATH_PURPOSE, derivePrivateKey: true, hardened: true)?
            .derive(index: Network.Ethereum.nId, derivePrivateKey: true, hardened: true)
        guard let newkey = key else { throw HDWalletError.dataError }
        pk = newkey
    }
    
    func pubKey(path: KeyPath) throws -> Data {
        return try _pKey(for: path).publicKey
    }
    
    func privateKey(keyPath: KeyPath) throws -> Data {
        return try _pKey(for: keyPath).privateKey!
    }
    
    func address(path: KeyPath) throws -> String {
        return try EthereumPublicKey(bytes: _pKey(for: path).publicKey).address.hex(eip55: false)
    }
    
    func sign(data: Data, path: KeyPath) throws -> Data {
        let signature = try EthereumPrivateKey(bytes: _pKey(for: path).privateKey!).sign(message: data.bytes)
        var signData = Data(bytes: signature.r)
        signData.append(Data(bytes: signature.s))
        signData.append(UInt8(signature.v + 27))
        return data
    }
    
    func verify(data: Data, signature: Data, path: KeyPath) throws -> Bool {
        let ourPubKey = try EthereumPublicKey(bytes: _pKey(for: path).publicKey)
        let r = try EthereumQuantity(bytes: data.subdata(in: 0..<32))
        let s = try EthereumQuantity(bytes: data.subdata(in: 32..<64))
        let v = EthereumQuantity(integerLiteral: UInt64(data[64] - 27))
        let dataPubKey = try EthereumPublicKey(message: data.bytes, v: v, r: r, s: s)
        return ourPubKey == dataPubKey
    }
    
    private func _pKey(for path: KeyPath) throws -> EthereumHDNode {
        guard path.address == 0 && path.change == 0 && path.coin == Network.Ethereum.nId && path.purpose == BIP44_KEY_PATH_PURPOSE else {
            throw HDWalletError.wrongKeyPath
        }
        let key = pk
            .derive(index: path.account, derivePrivateKey: true, hardened: true)?
            .derive(index: 0, derivePrivateKey: true, hardened: false)?
            .derive(index: 0, derivePrivateKey: true, hardened: false)
        guard let newkey = key else { throw HDWalletError.keyGenerationError }
        return newkey
    }
}
