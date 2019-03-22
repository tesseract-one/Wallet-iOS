//
//  Storage.swift
//  TesSDK
//
//  Created by Yehor Popovych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit

private let encoder: JSONEncoder = {
    let enc = JSONEncoder()
    enc.dataEncodingStrategy = .base64
    enc.dateEncodingStrategy = .iso8601
    return enc
}()

private let decoder: JSONDecoder = {
    let dec = JSONDecoder()
    dec.dataDecodingStrategy = .base64
    dec.dateDecodingStrategy = .iso8601
    return dec
}()

let WALLET_IDS_KEY = "WALLET_ID_LIST"
let ID_LOCK = NSLock()

extension UserDefaults: WalletStorageProtocol {
    private var _queue: DispatchQueue {
        return DispatchQueue.global()
    }
    
    public func listWalletIds(offset: Int, limit: Int, response: @escaping ([String], Error?) -> Void) {
        _queue.async {
            ID_LOCK.lock()
            defer { ID_LOCK.unlock() }
            guard let ids = self.array(forKey: WALLET_IDS_KEY) as? [String] else {
                response([], nil)
                return
            }
            response(ids, nil)
        }
    }
    
    public func hasWallet(id: String, response: @escaping (Bool?, Error?) -> Void) {
        _queue.async {
            let has = self.data(forKey: self._walletKey(id: id)) != nil
            return response(has, nil)
        }
        
    }
    
    public func loadWallet(id: String, response: @escaping (Wallet.StorageData?, Error?) -> Void) {
        _queue.async {
            do {
                guard let data = self.data(forKey: self._walletKey(id: id)) else {
                    response(nil, WalletStorageError.noData(forKey: self._walletKey(id: id)))
                    return
                }
                do {
                    response(try decoder.decode(Wallet.StorageData.self, from: data), nil)
                } catch let err {
                    response(nil, err)
                }
            }
        }
    }
    
    public func saveWallet(wallet: Wallet.StorageData, response: @escaping (Error?) -> Void) {
        _queue.async {
            do {
                self.set(try encoder.encode(wallet), forKey: self._walletKey(id: wallet.id))
                self._insertId(id: wallet.id)
                response(nil)
            } catch let err {
                response(err)
            }
        }
    }
    
    public func removeWallet(id: String, response: @escaping (Error?) -> Void) {
        _queue.async {
            self._removeId(id: id)
            self.set(nil, forKey: self._walletKey(id: id))
            response(nil)
        }
    }
    
    private func _insertId(id: String) {
        ID_LOCK.lock()
        defer { ID_LOCK.unlock() }
        var ids = self.array(forKey: WALLET_IDS_KEY) as? [String] ?? []
        if ids.firstIndex(of: id) == nil {
            ids.append(id)
        }
        self.set(ids, forKey: WALLET_IDS_KEY)
    }
    
    private func _removeId(id: String) {
        ID_LOCK.lock()
        defer { ID_LOCK.unlock() }
        var ids = self.array(forKey: WALLET_IDS_KEY) as? [String] ?? []
        ids.removeAll { $0 == id }
        self.set(ids, forKey: WALLET_IDS_KEY)
    }
    
    public func loadTransactions<T: SerializableValueDecodable>(
        query: WalletStorageQuery,
        response: @escaping (Array<T>?, Error?) -> Void
    ) {
        fatalError("Not implemented")
    }
    
    public func saveTransactions<T: SerializableValueEncodable>(
        transactions: Array<T>,
        response: @escaping (Error?) -> Void
    ) {
        fatalError("Not implemented")
    }
    
    public func loadTokens<T: SerializableValueDecodable>(
        query: WalletStorageQuery,
        response: @escaping (Array<T>?, Error?) -> Void
    ) {
        fatalError("Not implemented")
    }
    public func saveTokens<T: SerializableValueEncodable>(
        transactions: Array<T>,
        response: @escaping (Error?) -> Void
    ) {
        fatalError("Not implemented")
    }
    
    private func _walletKey(id: String) -> String {
        return "WALLET_" + id
    }
}
