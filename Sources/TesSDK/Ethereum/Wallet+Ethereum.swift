//
//  Wallet+Ethereum.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/6/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit
import Web3

extension Account {
    public func eth_address() throws -> String {
        if let ethAddrs = addresses[.Ethereum] {
            return ethAddrs[0].address
        }
        throw HDWalletError.networkIsNotSupported(.Ethereum)
    }
}

extension Wallet: EthereumSignProvider {
    public func eth_accounts() -> Promise<Array<String>> {
        return Promise().map { try self.accounts.map { try $0.eth_address() } }
    }
    
    public func eth_signTx(tx: EthereumTransaction, chainId: EthereumQuantity) -> Promise<EthereumSignedTransaction> {
        guard let account = tx.from?.hex(eip55: false) else {
            return Promise(error: EthereumSignProviderError.emptyAccount)
        }
        return eth_account(address: account)
            .then { $0.eth_signTx(tx: tx, chainId: chainId) }
    }
    
//    public func eth_verify(account: String, data: Data, signature: Data) -> Promise<Bool> {
//        return eth_account(address: account)
//            .then { $0.eth_verify(data: data, signature: signature) }
//    }
    
    public func eth_signData(account: String, data: Data) -> Promise<Data> {
        return eth_account(address: account)
            .then { $0.eth_signData(data: data) }
    }
    
    //    func eth_signTypedData(account: String) -> Promise<Array<UInt8>> {
    //        <#code#>
    //    }
    
    private func eth_account(address: String) -> Promise<Account> {
        let accounts = self.accounts
        return Promise().map {
            let opAccount = try accounts.first { try $0.eth_address() == address }
            guard let account = opAccount else {
                throw EthereumSignProviderError.accountDoesNotExist(address)
            }
            return account
        }
    }
}

extension Account {
    fileprivate func eth_signTx(tx: EthereumTransaction, chainId: EthereumQuantity) -> Promise<EthereumSignedTransaction> {
        //TODO: Rewrite this SHIT to secure methods
        return eth_hdwallet()
            .map { try $0.privateKey(network: .Ethereum, keyPath: self.keyPath) }
            .map { try EthereumPrivateKey(bytes: $0) }
            .map { try tx.sign(with: $0, chainId: chainId) }
    }
    
//    fileprivate func eth_verify(data: Data, signature: Data) -> Promise<Bool> {
//        return eth_hdwallet()
//            .map { try $0.verify(network: .Ethereum, data: data, signature: signature, path: self.keyPath) }
//    }
    
    fileprivate func eth_signData(data: Data) -> Promise<Data> {
        return eth_hdwallet()
            .map {
                var signData = "\u{19}Ethereum Signed Message:\n".data(using: .utf8)!
                signData.append(String(describing: data.count).data(using: .utf8)!)
                signData.append(data)
                return try $0.sign(network: .Ethereum, data: signData, path: self.keyPath)
        }
    }
    
    private var keyPath: EthereumKeyPath {
        return EthereumKeyPath(account: index)
    }
    
    private func eth_hdwallet() -> Promise<HDWallet> {
        if let support = networkSupport[.Ethereum] as? EthereumWalletNetworkSupport {
            return Promise.value(support.hdWallet)
        }
        return Promise(error: HDWalletError.networkIsNotSupported(.Ethereum))
    }
}

public struct EthereumWalletNetwork: WalletNetworkSupportFactory {
    public let network: Network
    
    public init() {
        network = .Ethereum
    }
    
    public func withHdWallet(wallet: HDWallet) -> WalletNetworkSupport {
        return EthereumWalletNetworkSupport(hdWallet: wallet)
    }
}

struct EthereumWalletNetworkSupport: WalletNetworkSupport {
    let hdWallet: HDWallet
    
    init(hdWallet: HDWallet) {
        self.hdWallet = hdWallet
    }
    
    func createFirstAddress(accountIndex: UInt32) throws -> Address {
        let address = try self.hdWallet.address(network: .Ethereum, path: EthereumKeyPath(account: accountIndex))
        return Address(index: 0, address: address, network: .Ethereum)
    }
}
