//
//  SettingsViewModels.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import UIKit
import ReactiveKit
import Wallet


class SettingWithWordVM: ViewModel {
    let title: String
    let description: String?
    let word: Property<String>
    let isEnabled: Bool
    let action: SafePublishSubject<Void>?
    
    init(title: String, description: String? = nil, word: Property<String>, isEnabled: Bool, action: SafePublishSubject<Void>? = nil) {
        self.title = title
        self.description = description
        self.word = word
        self.isEnabled = isEnabled
        self.action = isEnabled ? action! : nil
        
        super.init()
    }
}

class SettingWithIconVM: ViewModel {
    let title: String
    let description: String
    let icon: UIImage
    let action: SafePublishSubject<Void>
    
    init(title: String, description: String, icon: UIImage, action: SafePublishSubject<Void>) {
        self.title = title
        self.description = description
        self.icon = icon
        self.action = action
        
        super.init()
    }
}

class SettingWithSwitchVM: ViewModel {
    let title: String
    let description: String
    var isEnabled: Bool
    let switchAction: SafePublishSubject<Bool>
    
    init(title: String, description: String, key: SettingKeys, settings: Settings, switchAction: SafePublishSubject<Bool>, defaultValue: Bool) {
        self.title = title
        self.description = description
        self.switchAction = switchAction
        
        if let value = settings.number(forKey: key) as? Bool {
            self.isEnabled = value
        } else {
            self.isEnabled = defaultValue
        }
        
        super.init()
        
        switchAction.with(weak: self)
            .observeNext { newValue, sself in
                sself.isEnabled = newValue // should update is
                settings.set(newValue, forKey: key)
            }.dispose(in: bag)
    }
}

class SettingWithAccountVM: ViewModel {
    let name: Property<String>
    let balance = Property<String>("")
    let emoji: Property<String>
    let accountId: String
    let editAction: SafePublishSubject<String>
    
    init (account: AccountViewModel, changeRateService: ChangeRateService, editAction: SafePublishSubject<String>) {
        self.name = account.name
        self.emoji = account.emoji
        self.accountId = account.id
        self.editAction = editAction
        
        super.init()
        
        combineLatest(account.balance, changeRateService.changeRates[.Ethereum]!)
            .map { balance, rate -> String in
                guard let balance = balance else {
                    return "unknown"
                }
                
                let ethBalance = NumberFormatter.eth.string(from: balance as NSNumber)!
                let usdBalance = NumberFormatter.usd.string(from: (balance * rate) as NSNumber)!
                return "\(ethBalance) · \(usdBalance)"
            }
            .bind(to: balance)
            .dispose(in: bag)
    }
}

class ButtonWithIconVM: ViewModel {
    let title: String
    let icon: UIImage
    let action: SafePublishSubject<Void>
    
    init(title: String, icon: UIImage, action: SafePublishSubject<Void>) {
        self.title = title
        self.icon = icon
        self.action = action
        
        super.init()
    }
}

class LogoutVM: ViewModel {
    let title: String
    let action: SafePublishSubject<Void>
    
    init(title: String, action: SafePublishSubject<Void>) {
        self.title = title
        self.action = action
        
        super.init()
    }
}
