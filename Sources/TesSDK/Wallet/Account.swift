//
//  Account.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/6/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

public struct Address: Codable {
    let index: UInt32
    let address: String
    let network: Network
}

public class Account {
    public let index: UInt32
    public var name: String
    public private(set) var addresses: Dictionary<Network, Array<Address>>
    
    public private(set) var networkSupport: Dictionary<Network, WalletNetworkSupport> = [:]
    
    init(index: UInt32, name: String, addresses: Dictionary<Network, Array<Address>>) {
        self.index = index
        self.addresses = addresses
        self.name = name
    }
    
    init(index: UInt32, name: String, networkSupport: Dictionary<Network, WalletNetworkSupport>? = nil) throws {
        self.index = index
        self.addresses = [:]
        self.name = name
        
        if let supported = networkSupport {
            try setNetworkSupport(supported: supported)
        }
    }
    
    func setNetworkSupport(supported: Dictionary<Network, WalletNetworkSupport>) throws {
        networkSupport = supported
        
        for support in networkSupport {
            if addresses[support.key] == nil || addresses[support.key]!.count == 0 {
                addresses[support.key] = [try support.value.createFirstAddress(accountIndex: index)]
            }
        }
        
        let removed = Set(addresses.keys).subtracting(networkSupport.keys)
        for net in removed {
            addresses.removeValue(forKey: net)
        }
    }
}

extension Account {
    struct StorageData: Codable {
        let index: UInt32
        let name: String
        let addresses: Dictionary<Network, Array<Address>>
    }
    
    convenience init(storageData: StorageData) throws {
        self.init(index: storageData.index, name: storageData.name, addresses: storageData.addresses)
    }
    
    var storageData: StorageData {
        return StorageData(index: index, name: name, addresses: addresses)
    }
}
