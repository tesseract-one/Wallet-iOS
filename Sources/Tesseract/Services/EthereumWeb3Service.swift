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
import PMKFoundation
import Web3
import TesSDK

class EthereumWeb3Service {
    let bag = DisposeBag()
    
    var wallet: Property<Wallet?>!
    var ethereumAPIs: Property<EthereumAPIs?> = Property(nil)
    
    var endpoints: Dictionary<Int, String> = [
        1: "https://mainnet.infura.io/v3/f20390fe230e46608572ac4378b70668",
        2: "https://ropsten.infura.io/v3/f20390fe230e46608572ac4378b70668",
        3: "https://kovan.infura.io/v3/f20390fe230e46608572ac4378b70668",
        4: "https://rinkeby.infura.io/v3/f20390fe230e46608572ac4378b70668"
    ]
    
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
        web3.activeAccount = account.address
        return web3.eth
            .getBalance(address: try! EthereumAddress(hex: account.address, eip55: false), block: .latest)
            .map { Double($0.quantity) / pow(10.0, 18) }
    }
    
    func sendEthereum(account: Int, to: String, amountEth: Double, networkId: Int) -> Promise<Void> {
        var web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!, chainId: networkId)
        let account = wallet.value!.accounts[account]
        web3.activeAccount = account.address
        let tx = EthereumTransaction(
            from: try! EthereumAddress(hex: account.address, eip55: false),
            to: EthereumAddress(hexString: to)!,
            value: EthereumQuantity(integerLiteral: UInt64(amountEth * pow(10.0, 18)))
        )
        return web3.eth.sendTransaction(transaction: tx).asVoid()
    }
    
    func estimateGas(call: EthereumCall, networkId: Int) -> Promise<Double> {
        let web3 = ethereumAPIs.value!.web3(rpcUrl: endpoints[networkId]!, chainId: networkId)
        return web3.eth.estimateGas(call: call).map { Double($0.quantity) / pow(10.0, 18) }
    }
    
    func estimateGas(account: Int, to: String, amountEth: Double, networkId: Int) -> Promise<Double> {
        let account = wallet.value!.accounts[account]
        let call = EthereumCall(
            from: try! EthereumAddress(hex: account.address, eip55: false),
            to: EthereumAddress(hexString: to)!,
            value: EthereumQuantity(integerLiteral: UInt64(amountEth * pow(10.0, 18)))
        )
        return estimateGas(call: call, networkId: networkId)
    }
    
    func getTransactions(account: Int, networkId: Int) -> Promise<Array<EthereumTransactionLog>> {
        let etherscan = ethereumAPIs.value!.etherscan(apiUrl: etherscanEndpoints[networkId]!, apiToken: etherscanApiToken)
        return etherscan.getTransactions(address: wallet.value!.accounts[account].address)
    }
}
