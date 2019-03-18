//
//  Wallet.swift
//  Browser
//
//  Created by Yehor Popovych on 3/17/19.
//  Copyright © 2019 Daniel Leping. All rights reserved.
//

import Foundation
import Web3

extension NSError: JsonValueEncodable {
    public func encode() -> JsonValue {
        return JsonObject([
            "code": code,
            "domain": domain,
            "debug": debugDescription,
            "description": description
        ]).encode()
    }
}

extension JsonValue {
    static func error(_ err: Swift.Error) -> JsonValue {
        return .string("\(err)")
    }
}

class Wallet {
    typealias AccountRequest = (id: Int, method: String, cb: (Int, JsonValueEncodable?, JsonValueEncodable?) -> Void)
    private let endpoint:String
    
    private let web3: Web3
    private weak var webState: TesWebStateSink?
    
    private static var encoder = JSONEncoder()
    private static var decoder = JSONDecoder()
    
    private var account: EthereumAddress? = nil {
        didSet {
            if let account = account {
                webState?.setState(key: "account", value: account.hex(eip55: false))
            } else {
                webState?.setState(key: "account", value: nil)
            }
        }
    }
    
    private var pendingAccountsRequests: Array<AccountRequest> = []
    
    init(web3: Web3, endpoint: String, webState: TesWebStateSink) {
        self.web3 = web3
        self.endpoint = endpoint
        self.webState = webState
        request(id: 0, method: "eth_accounts", message: Data()) { _, _, _ in }
    }
    
    //rewrite to processors
    func request(
        id: Int, method:String, message: Data, callback: @escaping (Int, JsonValueEncodable?, JsonValueEncodable?) -> Void
    ) {
        //        let payload = WalletPayload.request(id: id, jsonrpc: jsonrpc, method: method, params: params)
        print("REQ", String(data: message, encoding: .utf8) ?? "UNKNOWN")
        switch method {
        case "eth_accounts":
            fallthrough
        case "eth_coinbase":
            if let account = self.account {
                if method == "eth_coinbase" {
                    callback(id, nil, account.hex(eip55: false))
                } else {
                    callback(id, nil, [account.hex(eip55: false)])
                }
            } else {
                pendingAccountsRequests.append((id: id, method: method, cb: callback))
                if pendingAccountsRequests.count == 1 {
                    web3.eth.accounts() { res in
                        switch res.status {
                        case .success(let accounts):
                            self.account = accounts.first
                            self._respondToAccounts(err: nil, accs: accounts)
                        case .failure(let err): self._respondToAccounts(err: JsonValue.error(err), accs: nil)
                        }
                    }
                }
            }
        case "eth_signTypedData": fallthrough
        case "personal_signTypedData":
            let params = try! Wallet.decoder.decode(RPCRequest<EthereumSignTypedDataCallParams>.self, from: message).params
            web3.eth.signTypedData(account: params.account, data: params.data) { res in
                switch res.status {
                case .success(let data): callback(id, nil, data.hex().jsv)
                case .failure(let err): callback(id, JsonValue.error(err), nil)
                }
            }
        case "personal_sign":
            let params = try! Wallet.decoder.decode(RPCRequest<[EthereumValue]>.self, from: message).params
            let account = try! EthereumAddress(ethereumValue: params[1])
            web3.personal.sign(message: params[0].ethereumData!, account: account, password: "") { res in
                switch res.status {
                case .success(let data): callback(id, nil, data.hex().jsv)
                case .failure(let err): callback(id, JsonValue.error(err), nil)
                }
            }
        case "eth_sign":
            let params = try! Wallet.decoder.decode(RPCRequest<[EthereumValue]>.self, from: message).params
            let account = try! EthereumAddress(ethereumValue: params[0])
            web3.eth.sign(account: account, message: params[1].ethereumData!) { res in
                switch res.status {
                case .success(let data): callback(id, nil, data.hex().jsv)
                case .failure(let err): callback(id, JsonValue.error(err), nil)
                }
            }
        case "eth_sendTransaction":
            let tx = try! Wallet.decoder.decode(RPCRequest<[EthereumTransaction]>.self, from: message).params[0]
            web3.eth.sendTransaction(transaction: tx) { res in
                switch res.status {
                case .success(let txData): callback(id, nil, txData.hex().jsv)
                case .failure(let err):
                    if let web3Err = err as? RPCResponse<EthereumData>.Error {
                        callback(id, JsonObject(["code": web3Err.code, "message": web3Err.message]), nil)
                    } else {
                        callback(id, JsonValue.error(err), nil)
                    }
                }
            }
        case "eth_newFilter":
            let params = try! Wallet.decoder.decode(RPCRequest<[EthereumNewFilterParams]>.self, from: message).params[0]
            web3.eth.newFilter(fromBlock: params.fromBlock, toBlock: params.toBlock, address: params.address, topics: params.topics) { res in
                switch res.status {
                case .success(let data): callback(id, nil, data.hex().jsv)
                case .failure(let err): callback(id, JsonValue.error(err), nil)
                }
            }
        case "eth_newPendingTransactionFilter":
            web3.eth.newPendingTransactionFilter() { res in
                switch res.status {
                case .success(let data): callback(id, nil, data.hex().jsv)
                case .failure(let err): callback(id, JsonValue.error(err), nil)
                }
            }
        case "eth_newBlockFilter":
            web3.eth.newBlockFilter() { res in
                switch res.status {
                case .success(let data): callback(id, nil, data.hex().jsv)
                case .failure(let err): callback(id, JsonValue.error(err), nil)
                }
            }
        case "eth_getFilterLogs":
            let quantity = try! Wallet.decoder.decode(RPCRequest<[EthereumValue]>.self, from: message).params[0]
            web3.eth.getFilterLogs(id: quantity.ethereumQuantity!) { res in
                switch res.status {
                case .success(let logs): callback(id, nil, self._asJsonObject(obj: logs))
                case .failure(let err): callback(id, JsonValue.error(err), nil)
                }
            }
            
        case "eth_getFilterChanges":
            let quantity = try! Wallet.decoder.decode(RPCRequest<[EthereumValue]>.self, from: message).params[0]
            web3.eth.getFilterChanges(id: quantity.ethereumQuantity!) { res in
                switch res.status {
                case .success(let obj): callback(id, nil, self._asJsonObject(obj: obj))
                case .failure(let err): callback(id, JsonValue.error(err), nil)
                }
            }
        case "eth_uninstallFilter":
            let quantity = try! Wallet.decoder.decode(RPCRequest<[EthereumValue]>.self, from: message).params[0]
            web3.eth.uninstallFilter(id: quantity.ethereumQuantity!) { res in
                switch res.status {
                case .success(let res): callback(id, nil, res)
                case .failure(let err): callback(id, JsonValue.error(err), nil)
                }
            }
        case "eth_call":
            var params = try! Wallet.decoder.decode(RPCRequest<EthereumCallParams>.self, from: message).params
            if params.from == nil, let account = self.account {
                let call = EthereumCall(
                    from: account, to: params.to, gas: params.gas,
                    gasPrice: params.gasPrice, value: params.value, data: params.data
                )
                params = EthereumCallParams(call: call, block: params.block)
            }
            web3.eth.call(call: params.call, block: params.block) { res in
                switch res.status {
                case .success(let data): callback(id, nil, data.hex())
                case .failure(let err): callback(id, JsonValue.error(err), nil)
                }
            }
        default:
            var req = try! Wallet.decoder.decode(JsonObject.self, from: message)
            req["id"] = web3.rpcId.jsv
            web3.provider.dataProvider.send(data: req.jsonData) { error, result in
                if let error = error {
                    callback(id, JsonValue.error(error), nil)
                } else if let result = result {
                    let js = try! Wallet.decoder.decode(JsonObject.self, from: result)
                    callback(id, nil, js["result"])
                } else {
                    callback(id, nil, nil)
                }
            }
        }
    }
    
    private func _respondToAccounts(err: JsonValueEncodable?, accs: [EthereumAddress]?) {
        if let err = err {
            for req in pendingAccountsRequests {
                req.cb(req.id, err, nil)
            }
        } else {
            for req in pendingAccountsRequests {
                if req.method == "eth_coinbase" {
                    req.cb(req.id, nil, accs?.first?.hex(eip55: false))
                } else {
                    req.cb(req.id, nil, accs?.map{$0.hex(eip55: false)})
                }
            }
        }
        pendingAccountsRequests.removeAll()
    }
    
    private func _asJsonObject<E: Encodable>(obj: E) -> JsonValue {
        let data = try! Wallet.encoder.encode(obj)
        return try! Wallet.decoder.decode(JsonValue.self, from: data)
    }
}


extension Wallet {
    func process(sink:TesWebSink, webMessage:TesWebMessage) -> Void {
        switch webMessage {
        case .message(id: let id, method: let method, message: let message):
            request(id: id, method: method, message: message) { id, error, result in
                sink.reply(id: id, error: error, result: result)
            }
        case .unknown(name: let name, data: let data):
            print("Unknown message: ", name, " with payload: ", data)
        }
    }
    
    func link(web: TesWebView) {
        web.addMessage(recepient: process)
    }
}
