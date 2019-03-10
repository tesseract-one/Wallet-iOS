//
//  OpenWallet+Keychain.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/7/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import PromiseKit

public class OpenWalletKeychainRequest<Request: OpenWalletRequestDataProtocol>: OpenWalletRequest<Request> {

    public init(network: Network, id: UInt32, request: Request) {
        super.init(id: id, request: request, uti: "org.openwallet.keychain.\(OpenWallet.networkUTIs[network]!)")
    }
    
    required public init(json: String, uti: String) throws {
        try super.init(json: json, uti: uti)
    }
}

extension OpenWallet {
    public func keychain<R: OpenWalletRequestDataProtocol>(net: Network, request: R) -> Promise<R.Response> {
        let req = OpenWalletKeychainRequest(network: net, id: requestId, request: request)
        return self.request(req)
    }
}
