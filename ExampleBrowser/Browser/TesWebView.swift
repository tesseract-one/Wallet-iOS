//
//  TesWebView.swift
//  CryptoKitties
//
//  Created by Daniel Leping on 15/09/2018.
//  Copyright © 2018 Daniel Leping. All rights reserved.
//

import Foundation
import WebKit
import Web3

public enum TesWebMessage {
    case message(id: Int, jsonrpc:String, method: String, params: [Any])
    case unknown(name: String, data: Any)
}

private extension WKScriptMessage {
    var tes:TesWebMessage {
        get {
            switch (self.name, self.body) {
            case ("tes", let string as String):
                let data = string.data(using: .utf8)
                return data.flatMap { data in
                    try? JSONSerialization.jsonObject(with: data, options: [])
                }.map { parsed in
                    let object: NSDictionary? = parsed as? NSDictionary
                    let id = object!["id"] as! Int
                    let jsonrpc = object!["jsonrpc"] as! String
                    let method = object!["method"] as! String
                    let params:[Any] = (object!["params"] as! NSArray).map {$0}
                    
                    return .message(id: id, jsonrpc: jsonrpc, method: method, params: params)
                }!
            case (let name, let body):
                return .unknown(name: name, data: body)
            }
        }
    }
}

public protocol TesWebSink : AnyObject {
    func reply(id: Int, error:Any?, result:Any?)
}

public protocol TesWebStateSink: AnyObject {
    func setState(key: String, value: Any?)
}

typealias TesWebRecepient = (TesWebSink, TesWebMessage)->Void

private class TesWebViewMessageHandler: NSObject, WKScriptMessageHandler {
    var recepients = [TesWebRecepient]()
    weak var sink:TesWebSink? = nil
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let sink = sink else {
            fatalError()
        }
        
        let msg = message.tes
        
        for recepient in recepients {
            recepient(sink, msg)
        }
    }
}

private func assembleJS(files: [String]) throws -> String {
    let paths = files.compactMap { file in
        Bundle.main.path(forResource: file, ofType: "js")
    }
    
    let contents = try paths.map { path in
        try String(contentsOfFile: path, encoding: .utf8)
    }
    
    let glued = contents.reduce("\n") { z, a in
        z + a + "\n"
    }
    
    return "(function(window) {" + glued + "})(window);"
}

public extension TesWebSink {
    public func reply(id: Int, result:Any?) {
        reply(id: id, error: nil, result: result)
    }
}

public class TesWebView : WKWebView, TesWebSink, TesWebStateSink {
    private let messageHandler = TesWebViewMessageHandler()
    
    public init(frame: CGRect, networkId: UInt64) {
        //let js = try! assembleJS(files: ["Web3Provider"])
        var js = "\nwindow.__ethereum_network_version = \(networkId);\n"
        js += try! String(contentsOfFile: Bundle.main.path(forResource: "Web3Provider", ofType: "js")!, encoding: .utf8)
        //let userScript = WKUserScript(source: "window.webkit.messageHandlers.send.postMessage(`lalala`);", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        
        contentController.add(messageHandler, name: "tes")
        
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        webViewConfiguration.userContentController = contentController
        
        super.init(frame: frame, configuration: webViewConfiguration)
        
        messageHandler.sink = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func addMessage(recepient:@escaping (TesWebSink, TesWebMessage)->Void) {
        messageHandler.recepients.append(recepient)
    }
    
    private func serialize(object:Any?) -> String? {
        return object.flatMap { object in
            switch object {
            case let string as String:
                return "\"\(string)\"".data(using: .utf8)
            case _ as NSNull:
                return nil
            case let number as IntegerLiteralType:
                return "\(number)".data(using: .utf8)
            case let number as FloatLiteralType:
                return "\(number)".data(using: .utf8)
            case let bool as BooleanLiteralType:
                return (bool ? "true" : "false").data(using: .utf8)
            case let err as Error:
                return "\"\(err.localizedDescription)\"".data(using: .utf8)
            default:
                return try? JSONSerialization.data(withJSONObject: object, options: [])
            }
        }.flatMap { data in
            String(data: data, encoding: .utf8)
        }.flatMap { string in
            string.replacingOccurrences(of: "'", with: "\\'")
        }
    }
    
    private func assembleMessageCall(id:Int, error:Any?, result:Any?) -> String {
        let err = error.flatMap(serialize) ?? "null"
        let res = result.flatMap(serialize) ?? "null"
        
        //print("window.web3.currentProvider.accept(\(id), '\(err)', '\(res)');")
        return "window.web3.currentProvider.accept(\(id), '\(err)', '\(res)');"
    }
    
    public func setState(key: String, value: Any?) {
        let k = serialize(object: key)!
        let v = value.flatMap(serialize) ?? "null"
        let js = "window.web3.currentProvider.setState('\(k)', '\(v)');"
        DispatchQueue.main.async {
            self.evaluateJavaScript(js)
        }
    }
    
    public func reply(id: Int, error:Any? = nil, result:Any?) {
        let js = assembleMessageCall(id: id, error: error, result: result)
        //print(js)
        DispatchQueue.main.async {
            self.evaluateJavaScript(js)
        }
    }
}
