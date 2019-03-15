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
import Web3
import TesSDK

class EthereumWeb3Service {
    let bag = DisposeBag()
    
    var wallet: Property<Wallet?>!
    let ethereumAPIs: Property<EthereumAPIs?> = Property(nil)

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
            .map { (wallet: Wallet?) -> EthereumAPIs? in
                guard let wallet = wallet else { return nil }
                return wallet.distributedAPI.Ethereum
            }
            .bind(to: ethereumAPIs)
            .dispose(in: bag)
    }
    
    func getBalance(account: Int, networkId: UInt64) -> Promise<Double> {
        let web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!)
        let account = wallet.value!.accounts[account]
        return web3.eth
            .getBalance(address: try! account.eth_address().web3, block: .latest)
            .map { Double($0.quantity) / pow(10.0, 18) }
    }
    
    func sendEthereum(account: Int, to: String, amountEth: Double, networkId: UInt64) -> Promise<Void> {
        let web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!)
        let account = wallet.value!.accounts[account]
        let tx = EthereumTransaction(
            from: try! account.eth_address().web3,
            to: try! EthereumAddress(hex: to, eip55: false),
            value: EthereumQuantity(integerLiteral: UInt64(amountEth * pow(10.0, 18)))
        )
        return web3.eth.sendTransaction(transaction: tx).asVoid()
    }
    
    func estimateGas(call: EthereumCall, networkId: UInt64) -> Promise<Double> {
        return _estimateGasWei(call: call, networkId: networkId).map{Double($0) / pow(10.0, 18)}
    }
    
    func isContract(address: String, networkId: UInt64) -> Promise<Bool> {
        let web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!)
        return Promise()
            .map { try Web3EthereumAddress(hex: address, eip55: false) }
            .then { address in
                web3.eth.getCode(address: address, block: .latest).map { data in
                    data.bytes.count > 0
                }
            }
    }
    
    func estimateSendTxGas(account: Int, to: String, amountEth: Double, networkId: UInt64) -> Promise<Double> {
        let account = wallet.value!.accounts[account]
        let gasPrice = _estimateGasPriceWei(networkId: networkId)
        
        let call = EthereumCall(
            from: try! account.eth_address().web3,
            to: try! Web3EthereumAddress(hex: to, eip55: false),
            value: EthereumQuantity(integerLiteral: UInt64(amountEth * pow(10.0, 18)))
        )
        let gasAmount = _estimateGasWei(call: call, networkId: networkId)
        return when(fulfilled: gasPrice, gasAmount)
            .map { $0.0 * $0.1 }
            .map{Double($0) / pow(10.0, 18)}
    }
    
    func estimateGasPrice(networkId: UInt64) -> Promise<Double> {
        return _estimateGasPriceWei(networkId: networkId).map{Double($0) / pow(10.0, 18)}
    }
    
    private func _estimateGasWei(call: EthereumCall, networkId: UInt64) -> Promise<BigUInt> {
        let web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!)
        return web3.eth.estimateGas(call: call).map{$0.quantity}
    }
    
    private func _estimateGasPriceWei(networkId: UInt64) -> Promise<BigUInt> {
        let web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!)
        return web3.eth.gasPrice().map{$0.quantity}
    }
    
    func getTransactions(account: Int, networkId: UInt64) -> Promise<Array<EthereumTransactionLog>> {
        let etherscan = ethereumAPIs.value!.etherscan(apiUrl: etherscanEndpoints[networkId]!, apiToken: etherscanApiToken)
        return etherscan.getTransactions(address: try! wallet.value!.accounts[account].eth_address().hex(eip55: false))
    }
}
