//
//  OpenWallet+Ethereum.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/7/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import PromiseKit
import Web3

public struct OpenWalletEthereumAccountKeychainRequest: OpenWalletRequestDataProtocol {
    public typealias Response = String
    public static let type: String = "eth_account"
    public let type: String = "eth_account"
    
    public init() {}
}

public struct OpenWalletEthereumSignTxKeychainRequest: OpenWalletRequestDataProtocol {
    public typealias Response = String
    public static let type: String = "eth_signTransaction"
    public let type: String = "eth_signTransaction"
    
    // From TX
    public let nonce: String
    public let from: String
    public let to: String
    public let gas: String
    public let gasPrice: String
    public let value: String
    public let data: String
    
    public let chainId: String
    
    public init(nonce: String, from: String, to: String,
                gas: String, gasPrice: String, value: String,
                data: String, chainId: String) {
        self.nonce = nonce
        self.from = from
        self.to = to
        self.gas = gas
        self.gasPrice = gasPrice
        self.value = value
        self.data = data
        self.chainId = chainId
    }
    
    public init(tx: EthereumTransaction, chainId: EthereumQuantity) {
        self.init(nonce: tx.nonce!.hex(), from: tx.from!.hex(eip55: false), to: tx.to!.hex(eip55: false),
                  gas: tx.gas!.hex(), gasPrice: tx.gasPrice!.hex(), value: tx.value!.hex(),
                  data: tx.data.hex(), chainId: chainId.hex())
    }
}

//public struct OpenWalletEthereumVerifyKeychainRequest: OpenWalletRequestDataProtocol {
//    public typealias Response = Bool
//    public static let type: String = "eth_verify"
//
//    public let account: String
//    public let data: String
//    public let signature: String
//}

public struct OpenWalletEthereumSignDataKeychainRequest: OpenWalletRequestDataProtocol {
    public typealias Response = String
    public static let type: String = "eth_signData"
    public let type: String = "eth_signData"
    
    public let account: String
    public let data: String
    
    public init(account: String, data: String) {
        self.account = account
        self.data = data
    }
}

extension OpenWallet: EthereumSignProvider {
    public func eth_accounts() -> Promise<Array<String>> {
        return keychain(net: .Ethereum, request: OpenWalletEthereumAccountKeychainRequest())
            .map { [$0] }
    }
    
    public func eth_signTx(tx: EthereumTransaction, chainId: EthereumQuantity) -> Promise<EthereumSignedTransaction> {
        return keychain(net: .Ethereum, request: OpenWalletEthereumSignTxKeychainRequest(tx: tx, chainId: chainId))
            .map { Data(hex: $0) }
            .map { data -> EthereumSignedTransaction in
                let bytes = data.makeBytes()
                let r = EthereumQuantity.bytes(Bytes(bytes[0..<32]))
                let s = EthereumQuantity.bytes(Bytes(bytes[32..<64]))
                let v = EthereumQuantity(integerLiteral: UInt64(bytes[64]) - 27)
                return EthereumSignedTransaction(
                    nonce: tx.nonce!, gasPrice: tx.gasPrice!, gasLimit: tx.gas!,
                    to: tx.to!, value: tx.value!, data: tx.data,
                    v: v, r: r,
                    s: s, chainId: chainId
                )
            }
    }
    
//    public func eth_verify(account: String, data: Data, signature: Data) -> Promise<Bool> {
//        return keychain(
//            net: .Ethereum,
//            request: OpenWalletEthereumVerifyKeychainRequest(
//                account: account, data: "0x" + data.toHexString(), signature: "0x" + signature.toHexString()
//            )
//        )
//    }
    
    public func eth_signData(account: String, data: Data) -> Promise<Data> {
        return keychain(
            net: .Ethereum,
            request: OpenWalletEthereumSignDataKeychainRequest(account: account, data: "0x" + data.toHexString())
        ).map { Data(hex: $0) }
    }
}


public protocol OpenWalletEthereumKeychainViewProvider {
    func accountRequestView(req: OpenWalletEthereumAccountKeychainRequest, cb: @escaping (Error?, OpenWalletEthereumAccountKeychainRequest.Response?) -> Void) -> UIViewController
    
    func signTransactionView(req: OpenWalletEthereumSignTxKeychainRequest, cb: @escaping (Error?, OpenWalletEthereumSignTxKeychainRequest.Response?) -> Void) -> UIViewController
    
    func signDataView(req: OpenWalletEthereumSignDataKeychainRequest, cb: @escaping (Error?, OpenWalletEthereumSignDataKeychainRequest.Response?) -> Void) -> UIViewController
}

public class OpenWalletEthereumKeychainRequestHandler: OpenWalletRequestHandler {
    public let supportedUTI: Array<String> = ["org.openwallet.keychain.ethereum"]
    
    private let viewProvider: OpenWalletEthereumKeychainViewProvider
    
    public init(viewProvider: OpenWalletEthereumKeychainViewProvider) {
        self.viewProvider = viewProvider
    }
    
    public func viewContoller(for type: String, request: String, uti: String, cb: @escaping Completion) throws -> UIViewController {
        switch type {
        case OpenWalletEthereumAccountKeychainRequest.type:
            let req = try OpenWalletRequest<OpenWalletEthereumAccountKeychainRequest>(json: request, uti: uti)
            return viewProvider.accountRequestView(req: req.data.request) { err, res in
                if let res = res {
                    cb(nil, req.response(data: res))
                } else {
                    cb(err, nil)
                }
            }
        case OpenWalletEthereumSignTxKeychainRequest.type:
            let req = try OpenWalletRequest<OpenWalletEthereumSignTxKeychainRequest>(json: request, uti: uti)
            return viewProvider.signTransactionView(req: req.data.request) { err, res in
                if let res = res {
                    cb(nil, req.response(data: res))
                } else {
                    cb(err, nil)
                }
            }
        case OpenWalletEthereumSignDataKeychainRequest.type:
            let req = try OpenWalletRequest<OpenWalletEthereumSignDataKeychainRequest>(json: request, uti: uti)
            return viewProvider.signDataView(req: req.data.request) { err, res in
                if let res = res {
                    cb(nil, req.response(data: res))
                } else {
                    cb(err, nil)
                }
            }
        default:
            throw OpenWalletError.wrongRequest(type)
        }
    }
}
