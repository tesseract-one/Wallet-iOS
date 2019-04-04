//
//  Settings.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

enum SettingKeys: String {
    case isDeveloperModeEnabled
    case activeAccountId
    case isBiometricEnabled
    case ethereumNetwork
    
    static let clearable: [SettingKeys] = [ .activeAccountId, .isBiometricEnabled ]
}

protocol Settings: class {
    func string(forKey: SettingKeys) -> String?
    func number(forKey: SettingKeys) -> NSNumber?
    func set(_ value: Any, forKey: SettingKeys)
    func removeObject(forKey: SettingKeys)
}

extension Settings {
    func clearSettings() {
        for setting in SettingKeys.clearable {
            removeObject(forKey: setting)
        }
    }
}

extension UserDefaults: Settings {
    
    func string(forKey: SettingKeys) -> String? {
        return string(forKey: forKey.rawValue)
    }
    
    func number(forKey: SettingKeys) -> NSNumber? {
        return object(forKey: forKey.rawValue) as? NSNumber
    }
    
    func set(_ value: Any, forKey: SettingKeys) {
        set(value, forKey: forKey.rawValue)
    }
    
    func removeObject(forKey: SettingKeys) {
        removeObject(forKey: forKey.rawValue)
    }
}
