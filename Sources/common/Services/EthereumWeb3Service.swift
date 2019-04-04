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
    let bag = DisposeBag()
    
    var wallet: Property<WalletViewModel?>!
    let ethereumAPIs: Property<APIRegistry?> = Property(nil)

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
            .map { (wallet: WalletViewModel?) -> APIRegistry? in
                guard let wallet = wallet else { return nil }
                return wallet.wallet.ethereum
            }
            .bind(to: ethereumAPIs)
            .dispose(in: bag)
    }
    
    func getBalance(accountId: String, networkId: UInt64) -> Promise<Double> {
        let web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!)
        let account = wallet.value!.account(id: accountId)!
        return web3.eth
            .getBalance(address: try! account.eth_address().web3, block: .latest)
            .map { $0.quantity.ethValue(precision: 9) }
    }
    
    func sendEthereum(accountId: String, to: String, amountEth: Double, networkId: UInt64) -> Promise<Void> {
        let web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!)
        let account = wallet.value!.account(id: accountId)!
        let tx = EthereumTransaction(
            from: try! account.eth_address().web3,
            to: try! EthereumAddress(hex: to, eip55: false),
            value: EthereumQuantity(quantity: BigUInt(amountEth * pow(10.0, 9)) * BigUInt(10).power(9))
        )
        return web3.eth.sendTransaction(transaction: tx).asVoid()
    }
    
    func estimateGas(call: EthereumCall, networkId: UInt64) -> Promise<Double> {
        return _estimateGasWei(call: call, networkId: networkId).map{$0.ethValue(precision: 9)}
    }
    
    func isContract(address: String, networkId: UInt64) -> Promise<Bool> {
        let web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!)
        return Promise()
            .map { try EthereumAddress(hex: address, eip55: false) }
            .then { address in
                web3.eth.getCode(address: address, block: .latest).map { data in
                    data.bytes.count > 0
                }
            }
    }
    
    func estimateSendTxGas(accountId: String, to: String, amountEth: Double, networkId: UInt64) -> Promise<Double> {
        let account = wallet.value!.account(id: accountId)!
        let gasPrice = _estimateGasPriceWei(networkId: networkId)
        
        let call = EthereumCall(
            from: try! account.eth_address().web3,
            to: try! EthereumAddress(hex: to, eip55: false),
            value: EthereumQuantity(quantity: BigUInt(amountEth * pow(10.0, 9)) * BigUInt(10).power(9))
        )
        let gasAmount = _estimateGasWei(call: call, networkId: networkId)
        return when(fulfilled: gasPrice, gasAmount)
            .map { $0.0 * $0.1 }
            .map{ $0.ethValue(precision: 9) }
    }
    
    func estimateGasPrice(networkId: UInt64) -> Promise<Double> {
        return _estimateGasPriceWei(networkId: networkId).map{$0.ethValue(precision: 9)}
    }
    
    private func _estimateGasWei(call: EthereumCall, networkId: UInt64) -> Promise<BigUInt> {
        let web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!)
        return web3.eth.estimateGas(call: call).map{$0.quantity}
    }
    
    private func _estimateGasPriceWei(networkId: UInt64) -> Promise<BigUInt> {
        let web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!)
        return web3.eth.gasPrice().map{$0.quantity}
    }
    
    func getTransactions(accountId: String, networkId: UInt64) -> Promise<Array<EthereumTransactionLog>> {
        let etherscan = ethereumAPIs.value!.etherscan(apiUrl: etherscanEndpoints[networkId]!, apiToken: etherscanApiToken)
        return etherscan.getTransactions(address: try! wallet.value!.account(id: accountId)!.eth_address().hex(eip55: false))
    }
}
