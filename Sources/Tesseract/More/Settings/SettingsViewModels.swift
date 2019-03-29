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
    let isEnabled: Bool
    let switchAction: SafePublishSubject<Bool>
    
    init(title: String, description: String, key: String, settings: UserDefaults, switchAction: SafePublishSubject<Bool>, defaultValue: Bool) {
        self.title = title
        self.description = description
        self.switchAction = switchAction
        
        if let value = settings.object(forKey: key) as? Bool {
            self.isEnabled = value
        } else {
            self.isEnabled = defaultValue
        }
        
        super.init()
        
        switchAction.with(weak: settings)
            .observeNext { newValue, settings in
                settings.set(newValue, forKey: key)
            }.dispose(in: bag)
    }
}

class SettingWithAccountVM: ViewModel {
    let name: String
    let balance = Property<String>("")
    let emoji: String
    let index: UInt32
    
    let web3Service: EthereumWeb3Service!
    let changeRateService: ChangeRateService!
    let network: Property<UInt64>
    
    private var updateTimer: Timer? = nil
    
    init (account: Account, web3Service: EthereumWeb3Service, changeRateService: ChangeRateService, network: Property<UInt64>) {
        self.web3Service = web3Service
        self.changeRateService = changeRateService
        self.network = network
        
        self.name = account.associatedData[.name]?.string ?? "Account"
        self.emoji = account.associatedData[.emoji]?.string ?? "\u{1F9B9}"
        self.index = account.index
        
        super.init()

        updateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.updateBalance()
        }
    }
    
    func updateBalance() {
        web3Service.getBalance(account: Int(index), networkId: network.value)
            .done(on: .main) { [weak self] balance in
                let ethBalance = "\(balance.rounded(toPlaces: 6)) ETH"
                let usdBalance = "\((balance * self!.changeRateService.changeRates[.Ethereum]!.value).rounded(toPlaces: 2)) USD"
                self?.balance.next("\(ethBalance) · \(usdBalance)")
            }
            .catch { [weak self] _ in
                self?.balance.next("unknown")
        }
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
