//
//  TesSDK.swift
//  TesSDK
//
//  Created by Yehor Popovych on 2/25/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

public struct Network: Hashable, Codable, RawRepresentable {
    public typealias RawValue = UInt32

    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
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
