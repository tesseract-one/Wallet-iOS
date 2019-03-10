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
import PromiseKit

public let TESSERACT_ETHEREUM_ENDPOINTS: Dictionary<Int, String> = [
    1: "https://mainnet.infura.io/v3/f20390fe230e46608572ac4378b70668",
    2: "https://ropsten.infura.io/v3/f20390fe230e46608572ac4378b70668",
    3: "https://kovan.infura.io/v3/f20390fe230e46608572ac4378b70668",
    4: "https://rinkeby.infura.io/v3/f20390fe230e46608572ac4378b70668"
]

class Wallet {
    private let endpoint:String
    
    private let web3: Web3
    
    init(web3: Web3, endpoint: String) {
        self.web3 = web3
        self.endpoint = endpoint
    }
    
    private func rpcRequest(id:Int, jsonrpc:String, method:String, params: [Any], callback: @escaping (Any?, Any?)->Void) {
        let data: [String: Any] = [
            "id": id,
            "method": method,
            "jsonrpc": jsonrpc,
            "params":  params
        ]
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
       
        switch method {
        case "eth_accounts":
            web3.eth.accounts() { res in
                switch res.status {
                case .success(let accounts): callback(id, nil, accounts.map{$0.hex(eip55: false)})
                case .failure(let err): callback(id, err, nil)
                }
            }
        case "eth_coinbase":
            web3.eth.accounts() { res in
                switch res.status {
                case .success(let accounts): callback(id, nil, accounts.map{$0.hex(eip55: false)}.first)
                case .failure(let err): callback(id, err, nil)
                }
            }
        case "eth_signTypedData":
            print("eth_signTypedData is not supported!")
            callback(id, "eth_signTypedData is not supported!", nil)
        case "personal_sign":
            let account = params.count > 1 ? try! EthereumAddress(hex: params[1] as! String, eip55: false) : nil
            web3.personal.sign(data: try! EthereumData(bytes: Data(hex: params[0] as! String)), account: account)
                .done { callback(id, nil, $0.hex()) }
                .catch { callback(id, $0, nil) }
        case "eth_sign":
            let account = try! EthereumAddress(hex: params[0] as! String, eip55: false)
            web3.personal.sign(data: try! EthereumData(bytes: Data(hex: params[1] as! String)), account: account)
                .done { callback(id, nil, $0.hex()) }
                .catch { callback(id, $0, nil) }
        case "eth_sendTransaction":
            let txDict = params[0] as! NSDictionary
            print("TX DICT", txDict)
            
            let nonce = txDict["nonce"] != nil ? EthereumQuantity.bytes(Bytes(hex: txDict["nonce"] as! String)) : nil
            let gas = txDict["gas"] != nil ? EthereumQuantity.bytes(Bytes(hex: txDict["gas"] as! String)) : nil
            let gasPrice = txDict["gasPrice"] != nil ? EthereumQuantity.bytes(Bytes(hex: txDict["gasPrice"] as! String)) : nil
            let tx = EthereumTransaction(
                nonce: nonce,
                gasPrice: gasPrice,
                gas: gas,
                from: try! EthereumAddress(hex: txDict["from"] as! String, eip55: false),
                to:  try! EthereumAddress(hex: txDict["to"] as! String, eip55: false),
                value: EthereumQuantity.bytes(Bytes(hex: txDict["value"] as! String)),
                data: EthereumData(raw: Bytes(hex: txDict["data"] as! String))
            )
            web3.eth.sendTransaction(transaction: tx) { res in
                switch res.status {
                case .success(let txData): callback(id, nil, txData.hex())
                case .failure(let err): callback(id, err, nil)
                }
            }
        default:
            print("BYPASS:", method)
            //TODO: add from to calls
            rpcRequest(id: id, jsonrpc: jsonrpc, method: method, params: params) { error, result in
                callback(id, error, result)
            }
        }
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
    var netVersion: Int? = nil
    
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
        
        let webView = TesWebView(frame: self.view.frame)
        
        let openWallet = (UIApplication.shared.delegate! as! AppDelegate).openWallet!
        let endpoint = TESSERACT_ETHEREUM_ENDPOINTS[netVersion!]!
        
        wallet = Wallet(web3: openWallet.distributedAPI.Ethereum.web3(rpcUrl: endpoint, chainId: netVersion!), endpoint: endpoint)
        
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

