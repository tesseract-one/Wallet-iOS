//
//  OpenWallet+Ethereum.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/7/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import PromiseKit
import BigInt

public protocol OpenWalletEthereumRequestDataProtocol: OpenWalletRequestDataProtocol {
    var networkId: UInt64 { get }
}

public struct OpenWalletEthereumAccountKeychainRequest: OpenWalletEthereumRequestDataProtocol {
    public typealias Response = String
    public static let type: String = "eth_account"
    public let type: String = "eth_account"
    
    public let networkId: UInt64
    
    public init(networkId: UInt64) {
        self.networkId = networkId
    }
}

public struct OpenWalletEthereumSignTxKeychainRequest: OpenWalletEthereumRequestDataProtocol {
    public typealias Response = String
    public static let type: String = "eth_signTransaction"
    public let type: String = "eth_signTransaction"
    
    public let networkId: UInt64
    
    // From TX
    public let nonce: String
    public let from: String
    public let to: String?
    public let gas: String
    public let gasPrice: String
    public let value: String
    public let data: String
    
    public let chainId: String
    
    public init(nonce: String, from: String, to: String? = nil,
                gas: String, gasPrice: String, value: String,
                data: String, chainId: String, networkId: UInt64) {
        self.nonce = nonce
        self.from = from
        self.to = to
        self.gas = gas
        self.gasPrice = gasPrice
        self.value = value
        self.data = data
        self.chainId = chainId
        self.networkId = networkId
    }
    
    public init(tx: EthereumTransaction, chainId: UInt64, networkId: UInt64) {
        self.init(
            nonce: "0x" + String(tx.nonce, radix: 16),
            from: tx.from.hex(eip55: false),
            to: tx.to?.hex(eip55: false),
            gas: "0x" + String(tx.gas, radix: 16),
            gasPrice: "0x" + String(tx.gasPrice, radix: 16),
            value: "0x" + String(tx.value, radix: 16),
            data: "0x" + tx.data.toHexString(),
            chainId: "0x" + String(BigUInt(chainId), radix: 16),
            networkId: networkId
        )
    }
    
    public var transaction: EthereumTransaction {
        return EthereumTransaction(
            nonce: BigUInt(remove0x(nonce), radix: 16)!,
            gasPrice: BigUInt(remove0x(gasPrice), radix: 16)!,
            gas: BigUInt(remove0x(gas), radix: 16)!,
            from: try! EthereumAddress(hex: from, eip55: false),
            to: to != nil ? try! EthereumAddress(hex: to!, eip55: false) : nil,
            value: BigUInt(remove0x(value), radix: 16)!,
            data: Data(hex: data))
    }
    
    public var chainIdInt: UInt64 {
        return UInt64(BigUInt(remove0x(chainId), radix: 16)!)
    }
    
    private func remove0x(_ str: String) -> String {
        return String(str.suffix(from: str.index(str.startIndex, offsetBy: 2)))
    }
}

public struct OpenWalletEthereumSignTypedDataKeychainRequest: OpenWalletEthereumRequestDataProtocol {
    public typealias Response = String
    public static let type: String = "eth_signTypedData"
    public let type: String = "eth_signTypedData"
    
    public let networkId: UInt64
    
    public let account: String
    
    public let types: Dictionary<String, Array<EIP712TypedData._Type>>
    public let primaryType: String
    public let domain: EIP712TypedData.Domain
    public let message: Dictionary<String, SerializableValue>
    
    public init(account: String, data: EIP712TypedData, networkId: UInt64) {
        self.networkId = networkId
        self.types = data.types
        self.primaryType = data.primaryType
        self.domain = data.domain
        self.message = data.message
        self.account = account
    }
    
    var typedData: EIP712TypedData {
        return EIP712TypedData(
            primaryType: primaryType,
            types: types,
            domain: domain,
            message: message
        )
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

public struct OpenWalletEthereumSignDataKeychainRequest: OpenWalletEthereumRequestDataProtocol {
    public typealias Response = String
    public static let type: String = "eth_signData"
    public let type: String = "eth_signData"
    
    public let networkId: UInt64
    
    public let account: String
    public let data: String
    
    public init(account: String, data: String, networkId: UInt64) {
        self.account = account
        self.data = data
        self.networkId = networkId
    }
}

extension OpenWallet: EthereumSignProvider {
    public func eth_accounts(networkId: UInt64) -> Promise<Array<EthereumAddress>> {
        return keychain(net: .Ethereum, request: OpenWalletEthereumAccountKeychainRequest(networkId: networkId))
            .map { [try EthereumAddress(hex: $0, eip55: false)] }
    }
    
    public func eth_signTx(tx: EthereumTransaction, networkId: UInt64, chainId: UInt64) -> Promise<Data> {
        return keychain(net: .Ethereum, request: OpenWalletEthereumSignTxKeychainRequest(tx: tx, chainId: chainId, networkId: networkId))
            .map { Data(hex: $0) }
    }
    
    public func eth_signTypedData(account: EthereumAddress, data: EIP712TypedData, networkId: UInt64) -> Promise<Data> {
        return keychain(
            net: .Ethereum,
            request: OpenWalletEthereumSignTypedDataKeychainRequest(account: account.hex(eip55: false), data: data, networkId: networkId)
        ).map { Data(hex: $0) }
    }
    
//    public func eth_verify(account: String, data: Data, signature: Data) -> Promise<Bool> {
//        return keychain(
//            net: .Ethereum,
//            request: OpenWalletEthereumVerifyKeychainRequest(
//                account: account, data: "0x" + data.toHexString(), signature: "0x" + signature.toHexString()
//            )
//        )
//    }
    
    public func eth_signData(account: EthereumAddress, data: Data, networkId: UInt64) -> Promise<Data> {
        return keychain(
            net: .Ethereum,
            request: OpenWalletEthereumSignDataKeychainRequest(account: account.hex(eip55: false), data: "0x" + data.toHexString(), networkId: networkId)
        ).map { Data(hex: $0) }
    }
}


public protocol OpenWalletEthereumKeychainViewProvider {
    func accountRequestView(req: OpenWalletEthereumAccountKeychainRequest, cb: @escaping (Error?, OpenWalletEthereumAccountKeychainRequest.Response?) -> Void) -> UIViewController
    
    func signTransactionView(req: OpenWalletEthereumSignTxKeychainRequest, cb: @escaping (Error?, OpenWalletEthereumSignTxKeychainRequest.Response?) -> Void) -> UIViewController
    
    func signDataView(req: OpenWalletEthereumSignDataKeychainRequest, cb: @escaping (Error?, OpenWalletEthereumSignDataKeychainRequest.Response?) -> Void) -> UIViewController
    
    func signTypedDataView(req: OpenWalletEthereumSignTypedDataKeychainRequest, cb: @escaping (Error?, OpenWalletEthereumSignTypedDataKeychainRequest.Response?) -> Void) -> UIViewController
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
        case OpenWalletEthereumSignTypedDataKeychainRequest.type:
            let req = try OpenWalletRequest<OpenWalletEthereumSignTypedDataKeychainRequest>(json: request, uti: uti)
            return viewProvider.signTypedDataView(req: req.data.request) { err, res in
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
