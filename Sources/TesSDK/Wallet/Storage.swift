//
//  StorageProtocol.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/21/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

public enum WalletStorageError: Error {
    case noData(forKey: String)
    case wrongData(forKey: String)
}

public struct WalletStorageQuery {
    public let offset: UInt32? = nil
    public let limit: UInt32? = nil
    public let sortBy: String? = nil
    public let ascending: Bool = true
    
    public var rules: Dictionary<String, SerializableValue> = [:]
}

public protocol WalletStorageProtocol {
    typealias Query = Dictionary<String, Any>
    
    func listWalletIds(offset: Int, limit: Int, response: @escaping ([String], Error?) -> Void)
    func hasWallet(id: String, response: @escaping (Bool?, Error?) -> Void)
    func loadWallet(id: String, response: @escaping (Wallet.StorageData?, Error?) -> Void)
    func saveWallet(wallet: Wallet.StorageData, response: @escaping (Error?) -> Void)
    func removeWallet(id: String, response: @escaping (Error?) -> Void)
    
    func loadTransactions<T: SerializableValueDecodable>(
        query: WalletStorageQuery,
        response: @escaping (Array<T>?, Error?) -> Void
    )
    func saveTransactions<T: SerializableValueEncodable>(
        transactions: Array<T>,
        response: @escaping (Error?) -> Void
    )
    
    func loadTokens<T: SerializableValueDecodable>(
        query: WalletStorageQuery,
        response: @escaping (Array<T>?, Error?) -> Void
    )
    func saveTokens<T: SerializableValueEncodable>(
        transactions: Array<T>,
        response: @escaping (Error?) -> Void
    )
}
