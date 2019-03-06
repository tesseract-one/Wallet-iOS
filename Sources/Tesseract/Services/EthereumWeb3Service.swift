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
    var ethereumAPIs: Property<EthereumAPIs?> = Property(nil)
    
    var endpoints: Dictionary<Int, String> = TESSERACT_ETHEREUM_ENDPOINTS
    
    var etherscanApiToken = "B7F32GXMBH169BF1SKBYPG4K8SKGSJGDGV"
    var etherscanEndpoints: Dictionary<Int, String> = [
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
    
    func getBalance(account: Int, networkId: Int) -> Promise<Double> {
        var web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!, chainId: networkId)
        let account = wallet.value!.accounts[account]
        web3.activeAccount = try! account.eth_address()
        return web3.eth
            .getBalance(address: try! EthereumAddress(hex: try! account.eth_address(), eip55: false), block: .latest)
            .map { Double($0.quantity) / pow(10.0, 18) }
    }
    
    func sendEthereum(account: Int, to: String, amountEth: Double, networkId: Int) -> Promise<Void> {
        var web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!, chainId: networkId)
        let account = wallet.value!.accounts[account]
        web3.activeAccount = try! account.eth_address()
        let tx = EthereumTransaction(
            from: try! EthereumAddress(hex: try! account.eth_address(), eip55: false),
            to: try! EthereumAddress(hex: to, eip55: false),
            value: EthereumQuantity(integerLiteral: UInt64(amountEth * pow(10.0, 18)))
        )
        return web3.eth.sendTransaction(transaction: tx).asVoid()
    }
    
    func estimateGas(call: EthereumCall, networkId: Int) -> Promise<Double> {
        return _estimateGasWei(call: call, networkId: networkId).map{Double($0) / pow(10.0, 18)}
    }
    
    func estimateSendTxGas(account: Int, to: String, amountEth: Double, networkId: Int) -> Promise<Double> {
        let account = wallet.value!.accounts[account]
        let gasPrice = _estimateGasPriceWei(networkId: networkId)
        
        let call = EthereumCall(
            from: try! EthereumAddress(hex: try! account.eth_address(), eip55: false),
            to: try! EthereumAddress(hex: to, eip55: false),
            value: EthereumQuantity(integerLiteral: UInt64(amountEth * pow(10.0, 18)))
        )
        let gasAmount = _estimateGasWei(call: call, networkId: networkId)
        return when(fulfilled: gasPrice, gasAmount)
            .map { $0.0 * $0.1 }
            .map{Double($0) / pow(10.0, 18)}
    }
    
    func estimateGasPrice(networkId: Int) -> Promise<Double> {
        return _estimateGasPriceWei(networkId: networkId).map{Double($0) / pow(10.0, 18)}
    }
    
    private func _estimateGasWei(call: EthereumCall, networkId: Int) -> Promise<BigUInt> {
        let web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!, chainId: networkId)
        return web3.eth.estimateGas(call: call).map{$0.quantity}
    }
    
    private func _estimateGasPriceWei(networkId: Int) -> Promise<BigUInt> {
        let web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!, chainId: networkId)
        return web3.eth.gasPrice().map{$0.quantity}
    }
    
    func getTransactions(account: Int, networkId: Int) -> Promise<Array<EthereumTransactionLog>> {
        let etherscan = ethereumAPIs.value!.etherscan(apiUrl: etherscanEndpoints[networkId]!, apiToken: etherscanApiToken)
        return etherscan.getTransactions(address: try! wallet.value!.accounts[account].eth_address())
    }
}
