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
    public private(set) var addresses: Dictionary<Network, Array<Address>>
    public var associatedData: Dictionary<String, AnySerializableObject>
    
    public private(set) var networkSupport: Dictionary<Network, WalletNetworkSupport> = [:]
    
    init(index: UInt32, addresses: Dictionary<Network, Array<Address>>, associatedData: Dictionary<String, AnySerializableObject>) {
        self.index = index
        self.addresses = addresses
        self.associatedData = associatedData
    }
    
    init(index: UInt32, networkSupport: Dictionary<Network, WalletNetworkSupport>? = nil) throws {
        self.index = index
        self.addresses = [:]
        self.associatedData = [:]
        
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
        let addresses: Dictionary<Network, Array<Address>>
        let associatedData: Dictionary<String, AnySerializableObject>
    }
    
    convenience init(storageData: StorageData) throws {
        self.init(index: storageData.index, addresses: storageData.addresses, associatedData: storageData.associatedData)
    }
    
    var storageData: StorageData {
        return StorageData(index: index, addresses: addresses, associatedData: associatedData)
    }
}
