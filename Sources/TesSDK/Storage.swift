//
//  Storage.swift
//  TesSDK
//
//  Created by Yehor Popovych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit

extension UserDefaults: StorageProtocol {
    public func hasData(key: String) -> Promise<Bool> {
        return Promise().map { self.data(forKey: key) != nil }
    }
    
    public func loadData(key: String) -> Promise<Data> {
        return Promise().map {
            if let data = self.data(forKey: key) {
                return data
            }
            throw StorageError.noData(forKey: key)
        }
    }
    
    public func saveData(key: String, data: Data) -> Promise<Void> {
        return Promise().map { self.set(data, forKey: key) }
    }
    
    public func removeData(key: String) -> Promise<Void> {
        return Promise().map { self.removeObject(forKey: key) }
    }
    
    
}
