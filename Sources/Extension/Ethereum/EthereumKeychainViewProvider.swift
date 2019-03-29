//
//  EthereumKeychainViewProvider.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import OpenWallet

class EthereumKeychainViewProvider: OpenWallet.EthereumKeychainViewProvider {
    
    let storyboard = UIStoryboard(name: "EthereumKeychain", bundle: nil)
    
    func accountRequestView(
        req: EthereumAccountKeychainRequest,
        cb: @escaping ViewResponse<EthereumAccountKeychainRequest>
    ) -> UIViewController {
        let vc = storyboard.instantiateViewController(withIdentifier: "AccountRequest") as! EthereumKeychainViewController<EthereumAccountKeychainRequest>
        vc.responseCb = cb
        vc.request = req
        return vc
    }
    
    func signTransactionView(req: EthereumSignTxKeychainRequest, cb: @escaping ViewResponse<EthereumSignTxKeychainRequest>) -> UIViewController {
        let vc = storyboard.instantiateViewController(withIdentifier: "SignTransactionRequest") as! EthereumKeychainViewController<EthereumSignTxKeychainRequest>
        vc.responseCb = cb
        vc.request = req
        return vc
    }
    
    func signDataView(req: EthereumSignDataKeychainRequest, cb: @escaping ViewResponse<EthereumSignDataKeychainRequest>) -> UIViewController {
        let vc = storyboard.instantiateViewController(withIdentifier: "SignDataRequest") as! EthereumKeychainViewController<EthereumSignDataKeychainRequest>
        vc.responseCb = cb
        vc.request = req
        return vc
    }
    
    func signTypedDataView(req: EthereumSignTypedDataKeychainRequest, cb: @escaping ViewResponse<EthereumSignTypedDataKeychainRequest>) -> UIViewController {
        let vc = storyboard.instantiateViewController(withIdentifier: "SignTypedDataRequest") as! EthereumKeychainViewController<EthereumSignTypedDataKeychainRequest>
        vc.responseCb = cb
        vc.request = req
        return vc
    }
}
