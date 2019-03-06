//
//  TesSDK.swift
//  TesSDK
//
//  Created by Yehor Popovych on 2/25/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

public struct Network: Hashable, Codable {
    public let nId: UInt32
}

public protocol NetworkAPI {
    func updateSignProvider(provider: SignProvider?)
}

public protocol SignProvider {
    var networks: Set<Network> { get }
}

open class dAPI {
    public var networkAPIs: Dictionary<Network, NetworkAPI> = [:]
    
    public var signProvider: SignProvider? = nil {
        didSet {
            updateSignProviderInNetworks()
        }
    }
}

extension dAPI {
    fileprivate func updateSignProviderInNetworks() {
        for (_, api) in networkAPIs {
            api.updateSignProvider(provider: signProvider)
        }
    }
}
