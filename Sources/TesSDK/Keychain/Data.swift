//
//  Data.swift
//  TesSDK
//
//  Created by Yehor Popovych on 2/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit

enum StorageError: Error {
    case noData(forKey: String)
    case internalError(err: Error)
}

public protocol StorageProtocol {
    func hasData(key: String) -> Promise<Bool>
    func loadData(key: String) -> Promise<Data>
    func saveData(key: String, data: Data) -> Promise<Void>
    func removeData(key: String) -> Promise<Void>
}

enum DataVersion: UInt16, Codable {
    case v1 = 1
}

enum DataError: Error {
    case encodeError
    case decodeError
    case unknownDataVersion
}

struct WalletDataV1: Codable {
    let keys: Dictionary<Network, Data>
}

struct WalletVersionedData: Codable {
    private let version: DataVersion
    private let data: Data
    
    init(v1: WalletDataV1) throws {
        do {
            let data = try JSONEncoder().encode(v1)
            self.version = .v1
            self.data = data
        } catch {
            throw DataError.encodeError
        }
    }
    
    static func from(data: Data) throws -> WalletVersionedData {
        do {
            return try JSONDecoder().decode(WalletVersionedData.self, from: data)
        } catch {
            throw DataError.decodeError
        }
    }
    
    func toData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    func walletData() throws -> WalletDataV1 {
        switch version {
        case .v1:
            do {
                return try JSONDecoder().decode(WalletDataV1.self, from: data)
            } catch {
                throw DataError.decodeError
            }
        }
    }
}
