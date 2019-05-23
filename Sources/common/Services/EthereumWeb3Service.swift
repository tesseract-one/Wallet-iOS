//
//  EthereumWeb3Service.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit
import PromiseKit
import EthereumWeb3
import Wallet

class EthereumWeb3Service {
    enum Error: Swift.Error {
        case accountNotFound(String)
        case ethereumAPIsNotInitialized
        case unknownNetwork(UInt64)
    }
    
    let bag = DisposeBag()
    
    var wallet: Property<WalletViewModel?>!
    let ethereumAPIs: Property<InstanceAPIRegistry?> = Property(nil)

    var endpoints: Dictionary<UInt64, String> = TESSERACT_ETHEREUM_ENDPOINTS
    
    var etherscanApiToken = "B7F32GXMBH169BF1SKBYPG4K8SKGSJGDGV"
    var etherscanEndpoints: Dictionary<UInt64, String> = [
        1: "https://api.etherscan.io",
        2: "https://api-ropsten.etherscan.io",
        3: "https://api-kovan.etherscan.io",
        4: "https://api-rinkeby.etherscan.io"
    ]
    
    func bootstrap() {
        wallet
            .map { wallet in wallet?.wallet.ethereum }
            .bind(to: ethereumAPIs)
            .dispose(in: bag)
    }
    
    private func _getAccount(id: String) -> Promise<AccountViewModel> {
        if let account = wallet.value?.account(id: id) {
            return Promise.value(account)
        }
        return Promise(error: Error.accountNotFound(id))
    }
    
    private func _getWeb3(networkId: UInt64) -> Promise<Web3> {
        guard let url = endpoints[networkId] else {
            return Promise(error: Error.unknownNetwork(networkId))
        }
        guard let apis = ethereumAPIs.value else {
            return Promise(error: Error.ethereumAPIsNotInitialized)
        }
        return Promise.value(apis.web3(rpcUrl: url))
    }
    
    func getBalance(accountId: String, networkId: UInt64) -> Promise<Double> {
        return _getWeb3(networkId: networkId)
            .then { web3 in self._getAccount(id: accountId).map { (web3, $0) } }
            .then { web3, account in
                web3.eth.getBalance(address: try account.eth_address())
            }
            .map { $0.quantity.ethValue(precision: 9) }
    }
    
    func sendEthereum(accountId: String, to: String, amountEth: Double, networkId: UInt64) -> Promise<Void> {
        let amount = BigUInt(amountEth * pow(10.0, 9)) * BigUInt(10).power(9)
        return _getWeb3(networkId: networkId)
            .then { web3 in self._getAccount(id: accountId).map { (web3, $0) } }
            .then { web3, account -> Promise<EthData> in
                let tx = try Transaction(
                    from: try account.eth_address(),
                    to: try Ethereum.Address(hex: to),
                    value: Quantity(amount)
                )
                return web3.eth.sendTransaction(transaction: tx)
            }.asVoid()
    }
    
    func estimateGas(call: Call, networkId: UInt64) -> Promise<Double> {
        return _estimateGasWei(call: call, networkId: networkId).map{$0.ethValue(precision: 9)}
    }
    
    func isContract(address: String, networkId: UInt64) -> Promise<Bool> {
        return _getWeb3(networkId: networkId)
            .map { ($0, try Ethereum.Address(hex: address)) }
            .then { web3, address in
                web3.eth.getCode(address: address, block: .latest)
            }
            .map { $0.data.count > 0 }
    }
    
    func estimateSendTxGas(accountId: String, to: String, amountEth: Double, networkId: UInt64) -> Promise<Double> {
        let amount = BigUInt(amountEth * pow(10.0, 9)) * BigUInt(10).power(9)
        let gasPrice = _estimateGasPriceWei(networkId: networkId)
        
        let gasAmount = _getAccount(id: accountId)
            .then { account -> Promise<BigUInt> in
                let call = Call(
                    from: try account.eth_address(),
                    to: try Ethereum.Address(hex: to),
                    value: Quantity(amount)
                )
                return self._estimateGasWei(call: call, networkId: networkId)
            }
        
        return when(fulfilled: gasPrice, gasAmount)
            .map { $0.0 * $0.1 }
            .map{ $0.ethValue(precision: 9) }
    }
    
    func estimateGasPrice(networkId: UInt64) -> Promise<Double> {
        return _estimateGasPriceWei(networkId: networkId).map{$0.ethValue(precision: 9)}
    }
    
    private func _estimateGasWei(call: Call, networkId: UInt64) -> Promise<BigUInt> {
        return _getWeb3(networkId: networkId)
            .then { $0.eth.estimateGas(call: call) }
            .map { $0.quantity }
    }
    
    private func _estimateGasPriceWei(networkId: UInt64) -> Promise<BigUInt> {
        return _getWeb3(networkId: networkId)
            .then { $0.eth.gasPrice() }
            .map { $0.quantity }
    }
    
    func getTransactions(accountId: String, networkId: UInt64) -> Promise<Array<EthereumTransactionLog>> {
        guard let apis = ethereumAPIs.value else {
            return Promise(error: Error.ethereumAPIsNotInitialized)
        }
        guard let url = etherscanEndpoints[networkId] else {
            return Promise(error: Error.unknownNetwork(networkId))
        }
        let etherscan = apis.etherscan(apiUrl: url, apiToken: etherscanApiToken)
        return _getAccount(id: accountId)
            .then { account -> Promise<[EthereumTransactionLog]> in
                let address = try account.eth_address().hex(eip55: false)
                return etherscan.getTransactions(address: address)
            }
    }
}
