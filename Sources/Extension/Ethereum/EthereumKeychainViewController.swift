//
//  EthereumKeychainViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK

class EthereumKeychainViewController<Request: OpenWalletRequestDataProtocol>: UIViewController {
    var responseCb: ((Error?, Request.Response?) -> Void)!
    var request: Request!
    
    func fail(error: Error) {
        responseCb(error, nil)
    }
    
    func succeed(response: Request.Response) {
        responseCb(nil, response)
    }
}
