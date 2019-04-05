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
    let activeDescription: Property<String>?
    let word: Property<String>
    let isEnabled: Bool
    let action: SafePublishSubject<Void>?
    
    init(title: String, description: String? = nil, activeDescription: Property<String>? = nil, word: Property<String>, isEnabled: Bool, action: SafePublishSubject<Void>? = nil) {
        self.title = title
        self.description = description
        self.activeDescription = activeDescription
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
    
    init (account: AccountViewModel, changeRateService: ChangeRateService) {
        self.name = account.name
        self.emoji = account.emoji
        self.accountId = account.id
        
        super.init()
        
        account.balance
            .with(weak: changeRateService)
            .map { balance, changeRateService -> String in
                guard let balance = balance else {
                    return "unknown"
                }
                
                let ethBalance = "\(balance.rounded(toPlaces: 6)) ETH"
                let usdBalance = "\((balance * changeRateService.changeRates[.Ethereum]!.value).rounded(toPlaces: 2)) USD"
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
