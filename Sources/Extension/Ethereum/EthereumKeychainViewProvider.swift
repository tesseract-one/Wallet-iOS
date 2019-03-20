//
//  EthereumKeychainViewProvider.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK

class EthereumKeychainViewProvider: OpenWalletEthereumKeychainViewProvider {
    let storyboard = UIStoryboard(name: "EthereumKeychain", bundle: nil)
    
    func accountRequestView(req: OpenWalletEthereumAccountKeychainRequest, cb: @escaping (Error?, OpenWalletEthereumAccountKeychainRequest.Response?) -> Void) -> UIViewController {
        let vc = storyboard.instantiateViewController(withIdentifier: "AccountRequest") as! EthereumKeychainViewController<OpenWalletEthereumAccountKeychainRequest>
        vc.responseCb = cb
        vc.request = req
        return vc
    }
    
    func signTransactionView(req: OpenWalletEthereumSignTxKeychainRequest, cb: @escaping (Error?, OpenWalletEthereumSignTxKeychainRequest.Response?) -> Void) -> UIViewController {
        let vc = storyboard.instantiateViewController(withIdentifier: "SignTransactionRequest") as! EthereumKeychainViewController<OpenWalletEthereumSignTxKeychainRequest>
        vc.responseCb = cb
        vc.request = req
        return vc
    }
    
    func signDataView(req: OpenWalletEthereumSignDataKeychainRequest, cb: @escaping (Error?, OpenWalletEthereumSignDataKeychainRequest.Response?) -> Void) -> UIViewController {
        let vc = storyboard.instantiateViewController(withIdentifier: "SignDataRequest") as! EthereumKeychainViewController<OpenWalletEthereumSignDataKeychainRequest>
        vc.responseCb = cb
        vc.request = req
        return vc
    }
    
    func signTypedDataView(
        req: OpenWalletEthereumSignTypedDataKeychainRequest,
        cb: @escaping (Error?, OpenWalletEthereumSignTypedDataKeychainRequest.Response?) -> Void
    ) -> UIViewController {
        let vc = storyboard.instantiateViewController(withIdentifier: "SignTypedDataRequest") as! EthereumKeychainViewController<OpenWalletEthereumSignTypedDataKeychainRequest>
        vc.responseCb = cb
        vc.request = req
        return vc
    }
}
