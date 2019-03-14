//
//  Ethereum.swift
//  TesSDK
//
//  Created by Yehor Popovych on 2/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

// "44'/60'/index'/0/0"
struct EthereumKeyPath: KeyPath {
    let account: UInt32
    
    var change: UInt32 { return 0 }
    var address: UInt32 { return 0 }
    var purpose: UInt32 { return BIP44_KEY_PATH_PURPOSE } // BIP44
    var coin: UInt32 { return Network.Ethereum.rawValue } // ETH Coin Type
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
            .derive(index: Network.Ethereum.rawValue, derivePrivateKey: true, hardened: true)
        guard let newkey = key else { throw HDWalletError.dataError }
        pk = newkey
    }
    
    func pubKey(path: KeyPath) throws -> Data {
        return try _pKey(for: path).publicKey
    }
    
    func address(path: KeyPath) throws -> String {
        guard let address = try _pKey(for: path).hexAddress(eip55: false) else {
            throw HDWalletError.internalError
        }
        return address
    }
    
    func sign(data: Data, path: KeyPath) throws -> Data {
        guard var signature = try _pKey(for: path).sign(data: data) else {
            throw HDWalletError.internalError
        }
        
        signature[64] = signature[64] + 27
        
        return signature
    }
    
    func verify(data: Data, signature: Data, path: KeyPath) throws -> Bool {
        guard signature.count == 65 else {
            throw HDWalletError.signatureError
        }
        var fixedSignature = signature
        fixedSignature[64] = fixedSignature[64] - 27
        
        guard let verified = try _pKey(for: path).verifySignature(message: data, signature: signature) else {
            throw HDWalletError.internalError
        }
        
        return verified
    }
    
    private func _pKey(for path: KeyPath) throws -> EthereumHDNode {
        guard path.address == 0 && path.change == 0 && path.coin == Network.Ethereum.rawValue && path.purpose == BIP44_KEY_PATH_PURPOSE else {
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
