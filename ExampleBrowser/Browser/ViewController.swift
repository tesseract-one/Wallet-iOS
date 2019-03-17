//
//  ViewController.swift
//  CryptoKitties
//
//  Created by Daniel Leping on 06/09/2018.
//  Copyright © 2018 Daniel Leping. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import TesSDK
import Web3

public let TESSERACT_ETHEREUM_ENDPOINTS: Dictionary<UInt64, String> = [
    1: "https://mainnet.infura.io/v3/f20390fe230e46608572ac4378b70668",
    2: "https://ropsten.infura.io/v3/f20390fe230e46608572ac4378b70668",
    3: "https://kovan.infura.io/v3/f20390fe230e46608572ac4378b70668",
    4: "https://rinkeby.infura.io/v3/f20390fe230e46608572ac4378b70668"
]

class Wallet {
    typealias AccountRequest = (id: Int, method: String, cb: (Int, Any?, Any?)->Void)
    private let endpoint:String
    
    private let web3: Web3
    private weak var webState: TesWebStateSink?
    
    private var account: Web3EthereumAddress? = nil {
        didSet {
            webState?.setState(key: "account", value: account?.hex(eip55: false))
        }
    }
    
    private var pendingAccountsRequests: Array<AccountRequest> = []
    
    init(web3: Web3, endpoint: String, webState: TesWebStateSink) {
        self.web3 = web3
        self.endpoint = endpoint
        self.webState = webState
        request(id: 0, jsonrpc: "2.0", method: "eth_accounts", params: []) { _, _, _ in }
    }
    
    private func rpcRequest(id:Int, jsonrpc:String, method:String, params: [Any], callback: @escaping (Any?, Any?)->Void) {
        let data: [String: Any] = [
            "id": id,
            "method": method,
            "jsonrpc": jsonrpc,
            "params":  params
        ]
        print("BYPASS CALL", data)
        Alamofire.request(endpoint, method: .post, parameters: data, encoding: JSONEncoding.default).responseString { response in
            switch response.result {
            case .success(let string):
                //print("!Response!" + string)
                let json = string.data(using: .utf8).flatMap {
                    try? JSONSerialization.jsonObject(with: $0, options: [])
                    }.flatMap {$0 as? NSDictionary}
                
                if let json = json {
                    //match int later
                    //let id = json["id"].flatMap {$0 as? Int}
                    print("BYPASS RESPONSE:", json)
                    callback(nil, json["result"])
                } else {
                    switch response.response?.statusCode {
                    case 405:
                        callback("Method '\(method)' not allowed. Request id: \(id)", nil)
                    //callback("mmmmmmmmmm", nil)
                    default:
                        callback("Not a JSON response to request: " + String(id), nil)
                    }
                    
                    
                }
            case .failure(let error):
                callback(error.localizedDescription, nil)
            }
        }
    }
    
    //rewrite to processors
    func request(id:Int, jsonrpc:String, method:String, params: [Any], callback: @escaping (Int, Any?, Any?)->Void) {
//        let payload = WalletPayload.request(id: id, jsonrpc: jsonrpc, method: method, params: params)
        print("ID:", id, "METHOD:", method, "PARAMS:", params)
        switch method {
        case "eth_accounts":
            fallthrough
        case "eth_coinbase":
            if let account = self.account {
                let param: Any = method == "eth_coinbase" ? account.hex(eip55: false) : [account.hex(eip55: false)]
                callback(id, nil, param)
            } else {
                pendingAccountsRequests.append((id: id, method: method, cb: callback))
                if pendingAccountsRequests.count == 1 {
                    web3.eth.accounts() { res in
                        switch res.status {
                        case .success(let accounts):
                            self.account = accounts.first
                            self._respondToAccounts(err: nil, accs: accounts)
                        case .failure(let err): self._respondToAccounts(err: err, accs: nil)
                        }
                    }
                }
            }
        case "eth_signTypedData":
            print("eth_signTypedData is not supported!")
            callback(id, "eth_signTypedData is not supported!", nil)
        case "personal_sign":
            let account = try! Web3EthereumAddress(hex: params[1] as! String, eip55: false)
            web3.personal.sign(message: try! EthereumData(bytes: Data(hex: params[0] as! String)), account: account, password: "") { res in
                switch res.status {
                case .success(let data): callback(id, nil, data.hex())
                case .failure(let err): callback(id, err, nil)
                }
            }
        case "eth_sign":
            let account = try! Web3EthereumAddress(hex: params[0] as! String, eip55: false)
            web3.personal.sign(message: try! EthereumData(bytes: Data(hex: params[1] as! String)), account: account, password: "") { res in
                switch res.status {
                case .success(let data): callback(id, nil, data.hex())
                case .failure(let err): callback(id, err, nil)
                }
            }
        case "eth_sendTransaction":
            let tx: Web3EthereumTransaction = _fromJsonObject(jsonObj: params[0])
            web3.eth.sendTransaction(transaction: tx) { res in
                switch res.status {
                case .success(let txData): callback(id, nil, txData.hex())
                case .failure(let err):
                    if let web3Err = err as? RPCResponse<EthereumData>.Error {
                        callback(id, ["code": web3Err.code, "message": web3Err.message], nil)
                    } else {
                        callback(id, err, nil)
                    }
                }
            }
        case "eth_newFilter":
            let params: EthereumNewFilterParams = _fromJsonObject(jsonObj: params[0])
            web3.eth.newFilter(fromBlock: params.fromBlock, toBlock: params.toBlock, address: params.address, topics: params.topics) { res in
                switch res.status {
                case .success(let data): callback(id, nil, data.hex())
                case .failure(let err): callback(id, err, nil)
                }
            }
        case "eth_newPendingTransactionFilter":
            web3.eth.newPendingTransactionFilter() { res in
                switch res.status {
                case .success(let data): callback(id, nil, data.hex())
                case .failure(let err): callback(id, err, nil)
                }
            }
        case "eth_newBlockFilter":
            web3.eth.newBlockFilter() { res in
                switch res.status {
                case .success(let data): callback(id, nil, data.hex())
                case .failure(let err): callback(id, err, nil)
                }
            }
        case "eth_getFilterLogs":
            web3.eth.getFilterLogs(id: EthereumQuantity.bytes(Bytes(hex: params[0] as! String))) { res in
                switch res.status {
                case .success(let logs): callback(id, nil, self._asJsonObject(obj: logs))
                case .failure(let err): callback(id, err, nil)
                }
            }
        
        case "eth_getFilterChanges":
            web3.eth.getFilterChanges(id: EthereumQuantity.bytes(Bytes(hex: params[0] as! String))) { res in
                switch res.status {
                case .success(let obj): callback(id, nil, self._asJsonObject(obj: obj))
                case .failure(let err): callback(id, err, nil)
                }
            }
        case "eth_uninstallFilter":
            web3.eth.uninstallFilter(id: EthereumQuantity.bytes(Bytes(hex: params[0] as! String))) { res in
                switch res.status {
                case .success(let res): callback(id, nil, res)
                case .failure(let err): callback(id, err, nil)
                }
            }
        case "eth_call":
            var params: EthereumCallParams = _fromJsonObject(jsonObj: params)
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
                case .failure(let err): callback(id, err, nil)
                }
            }
        default:
            rpcRequest(id: id, jsonrpc: jsonrpc, method: method, params: params) { error, result in
                callback(id, error, result)
            }
        }
    }
    
    private func _respondToAccounts(err: Any?, accs: [Web3EthereumAddress]?) {
        if let err = err {
            for req in pendingAccountsRequests {
                req.cb(req.id, err, nil)
            }
        } else {
            for req in pendingAccountsRequests {
                if req.method == "eth_coinbase" {
                    req.cb(req.id, nil, accs?.first?.hex(eip55: false))
                } else {
                    req.cb(req.id, nil, accs?.map {$0.hex(eip55: false)})
                }
            }
        }
        pendingAccountsRequests.removeAll()
    }
    
    private func _parseTopics(arr: NSArray) -> Array<EthereumTopic> {
        let json = try! JSONSerialization.data(withJSONObject: arr, options: [])
        return try! JSONDecoder().decode([EthereumTopic].self, from: json)
    }
    
    private func _fromJsonObject<E: Decodable>(jsonObj: Any) -> E {
        let json = try! JSONSerialization.data(withJSONObject: jsonObj, options: [])
        return try! JSONDecoder().decode(E.self, from: json)
    }
    
    private func _asJsonObject<E: Encodable>(obj: E) -> Any {
        let data = try! JSONEncoder().encode(obj)
        return try! JSONSerialization.jsonObject(with: data, options: [])
    }
}


extension Wallet {
    func process(sink:TesWebSink, webMessage:TesWebMessage) -> Void {
        switch webMessage {
        case .message(id: let id, jsonrpc: let jsonrpc, method: let method, params: let params):
            request(id: id, jsonrpc: jsonrpc, method: method, params: params) { id, error, result in
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

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    var appUrl: URL? = nil
    var netVersion: UInt64? = nil
    
    var wallet:Wallet? = nil
    
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        print("WALLA!")
    }
    
    func webView(_ webView: WKWebView,
                 didFail navigation: WKNavigation!,
                 withError error: Error) {
        print("WALLA2!")
    }
    
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("HOLA1")
        
        return nil
    }
    
    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        print("HOLA2")
    }
    
    func webView(_ webView: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        print("HOLA3")
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        print("HOLA4")
    }
    
    /*func webView(_ webView: WKWebView,
                 runOpenPanelWith parameters: WKOpenPanelParameters,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping ([URL]?) -> Void) {
        print("HOLA5")
    }*/
    
    func webView(_ webView: WKWebView,
                 shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        print("HOLA6")
        return true
    }
    
    func webView(_ webView: WKWebView,
                 previewingViewControllerForElement elementInfo: WKPreviewElementInfo,
                 defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {
        print("HOLA7")
        return nil
    }
    
    func webView(_ webView: WKWebView,
                 commitPreviewingViewController previewingViewController: UIViewController) {
        print("HOLA8")
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        print("JSMSG: " + message)
        /*webView.evaluateJavaScript("window.web3.isConnected();",
                                   completionHandler: {(res: AnyObject?, error: NSError?) in
                                    if let connected = res, connected as! NSInteger == 1
                                    {
                                        print("Connected to ethereum node")
                                    }
                                    else
                                    {
                                        print("Unable to connect ot the node. Check the setup.")
                                    }
                                    } as? (Any?, Error?) -> Void
        )*/
        completionHandler()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webView = TesWebView(frame: self.view.frame, networkId: netVersion!)
        
        let openWallet = (UIApplication.shared.delegate! as! AppDelegate).openWallet!
        let endpoint = TESSERACT_ETHEREUM_ENDPOINTS[netVersion!]!
        
        wallet = Wallet(
            web3: openWallet.distributedAPI.Ethereum.web3(rpcUrl: endpoint),
            endpoint: endpoint,
            webState: webView
        )
        
        let myRequest = URLRequest(url: appUrl!)
        
        title = appUrl?.host
    
        wallet?.link(web: webView)
        
        self.view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutConstraint.Attribute] = [.top, .bottom, .right, .left]
        NSLayoutConstraint.activate(attributes.map {
            NSLayoutConstraint(item: webView, attribute: $0, relatedBy: .equal, toItem: webView.superview, attribute: $0, multiplier: 1, constant: 0)
        })
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.load(myRequest)
        // Do any additional setup after loading the view, typically from a nib.
    }
}

