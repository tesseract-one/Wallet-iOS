//
//  Account.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/6/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

public struct Address: Codable, Equatable {
    let index: UInt32
    let address: EthereumAddress
    let network: Network
    
    public init(index: UInt32, address: EthereumAddress, network: Network) {
        self.index = index
        self.address = address
        self.network = network
    }
    
    public static func == (lhs: Address, rhs: Address) -> Bool {
        return lhs.index == rhs.index && lhs.address == rhs.address && lhs.network == rhs.network
    }
}

public class Account {
    public let id: String
    public let index: UInt32
    public private(set) var addresses: Dictionary<Network, Array<Address>>
    public var associatedData: Dictionary<AssociatedKeys, SerializableProtocol>
    
    public private(set) var networkSupport: Dictionary<Network, WalletNetworkSupport> = [:]
    
    init(
        id: String, index: UInt32,
        addresses: Dictionary<Network, Array<Address>>,
        associatedData: Dictionary<AssociatedKeys, SerializableProtocol>
    ) {
        self.id = id
        self.index = index
        self.addresses = addresses
        self.associatedData = associatedData
    }
    
    init(id: String, index: UInt32, networkSupport: Dictionary<Network, WalletNetworkSupport>? = nil) throws {
        self.id = id
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
    public struct AssociatedKeys: RawRepresentable, Codable, Hashable, Equatable {
        public typealias RawValue = String
        public let rawValue: RawValue
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    
    public struct StorageData: Codable, Equatable {
        public let id: String
        public let index: UInt32
        public let addresses: Dictionary<Network, Array<Address>>
        public let associatedData: Dictionary<String, SerializableValue>
        
        public init(
            id: String,
            index: UInt32,
            addresses: Dictionary<Network, Array<Address>>,
            associatedData: Dictionary<String, SerializableValue>
            ) {
            self.id = id
            self.index = index
            self.addresses = addresses
            self.associatedData = associatedData
        }
    }
    
    convenience init(storageData: StorageData) throws {
        var associatedData = Dictionary<AssociatedKeys, SerializableProtocol>()
        for (key, val) in storageData.associatedData {
            associatedData[AssociatedKeys(rawValue: key)] = val
        }
        self.init(
            id: storageData.id, index: storageData.index,
            addresses: storageData.addresses, associatedData: associatedData
        )
    }
    
    var storageData: StorageData {
        var data = Dictionary<String, SerializableValue>()
        for (key, val) in associatedData {
            data[key.rawValue] = val.serializable
        }
        return StorageData(
            id: id, index: index,
            addresses: addresses, associatedData: data
        )
    }
}

extension Account: Equatable {
    public static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.storageData == rhs.storageData
    }
}
