//
//  Wallet+Ethereum.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/6/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

public extension Wallet.AssociatedKeys {
    static let isMetamask = Wallet.AssociatedKeys(rawValue: "isMetamask")
}

extension Account {
    public func eth_address() throws -> EthereumAddress {
        if let ethAddrs = addresses[.Ethereum] {
            return ethAddrs[0].address
        }
        throw Keychain.Error.networkIsNotSupported(.Ethereum)
    }
}

extension Wallet: EthereumSignProvider {
    public func eth_accounts(networkId: UInt64) -> Promise<Array<EthereumAddress>> {
        return Promise().map { try self.accounts.map { try $0.eth_address() } }
    }
    
    public func eth_signTx(tx: EthereumTransaction, networkId: UInt64, chainId: UInt64) -> Promise<Data> {
        return eth_account(address: tx.from)
            .then { $0.eth_signTx(isMetamask: self.isMetamask, tx: tx, chainId: chainId) }
    }
    
//    public func eth_verify(account: String, data: Data, signature: Data) -> Promise<Bool> {
//        return eth_account(address: account)
//            .then { $0.eth_verify(data: data, signature: signature) }
//    }
    
    public func eth_signData(account: EthereumAddress, data: Data, networkId: UInt64) -> Promise<Data> {
        return eth_account(address: account)
            .then { $0.eth_signData(isMetamask: self.isMetamask, data: data) }
    }
    
    public func eth_signTypedData(account: EthereumAddress, data: EIP712TypedData, networkId: UInt64) -> Promise<Data> {
        return eth_account(address: account)
            .then { $0.eth_signTypedData(isMetamask: self.isMetamask, data: data) }
    }
    
    private func eth_account(address: EthereumAddress) -> Promise<Account> {
        let accounts = self.accounts
        return Promise().map {
            let opAccount = try accounts.first { try $0.eth_address() == address }
            guard let account = opAccount else {
                throw EthereumSignProviderError.accountDoesNotExist(address)
            }
            return account
        }
    }
    
    private var isMetamask: Bool {
        return associatedData[.isMetamask]?.bool ?? false
    }
}

extension Account {
    fileprivate func eth_signTx(isMetamask: Bool, tx: EthereumTransaction, chainId: UInt64) -> Promise<Data> {
        return eth_keychain()
            .map { try $0.sign(network: .Ethereum, data: tx.rawData(chainId: BigUInt(chainId)), path: self.keyPath(isMetamask)) }
    }
    
    fileprivate func eth_signTypedData(isMetamask: Bool, data: EIP712TypedData) -> Promise<Data> {
        return eth_keychain()
            .map { try $0.sign(network: .Ethereum, data: data.signableMessageData(), path: self.keyPath(isMetamask)) }
    }
    
//    fileprivate func eth_verify(data: Data, signature: Data) -> Promise<Bool> {
//        return eth_hdwallet()
//            .map { try $0.verify(network: .Ethereum, data: data, signature: signature, path: self.keyPath) }
//    }
    
    fileprivate func eth_signData(isMetamask: Bool, data: Data) -> Promise<Data> {
        return eth_keychain()
            .map {
                var signData = "\u{19}Ethereum Signed Message:\n".data(using: .utf8)!
                signData.append(String(describing: data.count).data(using: .utf8)!)
                signData.append(data)
                return try $0.sign(network: .Ethereum, data: signData, path: self.keyPath(isMetamask))
        }
    }
    
    private func keyPath(_ isMetamask: Bool) -> KeyPath {
        return isMetamask ? MetamaskKeyPath(address: index) : EthereumKeyPath(account: index)
    }
    
    private func eth_keychain() -> Promise<Keychain> {
        if let support = networkSupport[.Ethereum] as? EthereumWalletNetworkSupport {
            return Promise.value(support.keychain)
        }
        return Promise(error: Keychain.Error.networkIsNotSupported(.Ethereum))
    }
}

public struct EthereumWalletNetwork: WalletNetworkSupportFactory {
    public let network: Network
    
    public init() {
        network = .Ethereum
    }
    
    public func withKeychain(keychain: Keychain, for wallet: Wallet) -> WalletNetworkSupport {
        return EthereumWalletNetworkSupport(
            keychain: keychain,
            isMetamask: wallet.associatedData[.isMetamask]?.bool ?? false
        )
    }
}

protocol EthereumWalletKeychainNetworkSuppport: WalletNetworkSupport {
    var keychain: Keychain { get }
}

struct EthereumWalletNetworkSupport: WalletNetworkSupport {
    let keychain: Keychain
    let isMetamask: Bool
    
    init(keychain: Keychain, isMetamask: Bool) {
        self.keychain = keychain
        self.isMetamask = isMetamask
    }
    
    func createFirstAddress(accountIndex: UInt32) throws -> Address {
        let keyPath: KeyPath = isMetamask
            ? MetamaskKeyPath(address: accountIndex)
            : EthereumKeyPath(account: accountIndex)
        let address = try self.keychain.address(network: .Ethereum, path: keyPath)
        let ethAddress = try EthereumAddress(hex: address, eip55: false)
        return Address(index: 0, address: ethAddress, network: .Ethereum)
    }
}
