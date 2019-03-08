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
    public let network: Network
    
    init(network: Network, id: UInt32, request: Request) {
        self.network = network
        super.init(id: id, request: request)
    }
    
    open override func activityType() -> UIActivity.ActivityType {
        return UIActivity.ActivityType(rawValue: "\(super.activityType().rawValue).keychain")
    }
    
    open override func dataTypeUTI() -> String {
        return "\(self.activityType().rawValue).\(OpenWallet.networkUTIs[network]!)"
    }
}

extension OpenWallet {
    public func keychain<R: OpenWalletRequestDataProtocol>(net: Network, request: R) -> Promise<R.Response> {
        let req = OpenWalletKeychainRequest(network: net, id: requestId, request: request)
        return self.request(req)
    }
}
