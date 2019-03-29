//
//  SettingsViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit
import Bond
import Wallet


class SettingsViewModel: ViewModel, ForwardRoutableViewModelProtocol {
    let walletService: WalletService
    let web3Service: EthereumWeb3Service
    let changeRateService: ChangeRateService
    
    let wallet = Property<WalletState?>(nil)
    let network = Property<UInt64>(0)
    let settings: UserDefaults
    
    let tableSettings = MutableObservableArray2D<String, ViewModel>(Array2D())
    let accounts = MutableObservableArray<ViewModel>()
    
    let createAccountAction = SafePublishSubject<Void>()
    let currentConversion = Property<String>("USD")
    let primaryCurrency = Property<String>("ETH")
    let currentLanguage = Property<String>("ENG")
    let changePasswordAction = SafePublishSubject<Void>()
    let switchDeveloperModeAction = SafePublishSubject<Bool>()
    let currentNetwork = Property<String>("RKB")
    let currentNetworkDescription = Property<String>("Rinkeby Network")
    let changeNetworkAction = SafePublishSubject<Void>()
    let showInfoAboutTesseractAcion = SafePublishSubject<Void>()
    let logoutAction = SafePublishSubject<Void>()
    
    let goToView = SafePublishSubject<ToView>()
    
    init(walletService: WalletService, web3Service: EthereumWeb3Service, changeRateService: ChangeRateService, settings: UserDefaults) {
        self.walletService = walletService
        self.web3Service = web3Service
        self.changeRateService = changeRateService
        self.settings = settings
        
        super.init()
    }
    
    func bootstrap() {
        setupTableSettigns()
        
        wallet.with(weak: self)
            .map{ wallet, sself -> [ViewModel] in
                let accounts = wallet!.exists?.accounts ?? []
                var accountsVM: [ViewModel] = accounts.map { SettingWithAccountVM(account: $0, web3Service: sself.web3Service, changeRateService: sself.changeRateService, network: sself.network) }
                let createAccountVM = ButtonWithIconVM(title: "Create Account", icon:  UIImage(named: "plus")!, action: sself.createAccountAction)
                
                accountsVM.append(createAccountVM)
                
                return accountsVM
            }
            .bind(to: accounts)
            .dispose(in: bag)
        
        
        network.map { NETWORKS[Int($0) - 1].abbr }.bind(to: currentNetwork)
        network.map { NETWORKS[Int($0) - 1].name }.bind(to: currentNetworkDescription)
        
        switchDeveloperModeAction.with(weak: self).observeNext { isOn, sself in
            let numberOfItemsInDeveloperSection = sself.tableSettings.collection.numberOfItems(inSection: 2)

            if !isOn && numberOfItemsInDeveloperSection > 1 {
                for _ in 1 ... numberOfItemsInDeveloperSection - 1 {
                    sself.tableSettings.removeItem(at: IndexPath(row: 1, section: 2))
                }
            } else if isOn && numberOfItemsInDeveloperSection == 1 {
                sself.tableSettings.appendItem(
                    SettingWithWordVM(title: "Choose Network", activeDescription: sself.currentNetworkDescription, word: sself.currentNetwork, isEnabled: true, action: self.changeNetworkAction),
                    toSectionAt: 2
                )
            }
        }.dispose(in: bag)
        
        changeNetworkAction.map { _ in (name: "ChooseNetwork", context: nil) }
            .bind(to: goToView).dispose(in: bag)
        
        accounts.with(weak: tableSettings).observeNext { accounts, tableSettings in
            tableSettings.removeSection(at: 0)
            tableSettings.insert(section: "Your Accounts", at: 0)
            tableSettings.insert(contentsOf: accounts.collection, at: IndexPath(row: 0, section: 0))
        }.dispose(in: bag)
        
        logoutAction
            .with(weak: walletService)
            .with(latestFrom: wallet)
            .observeNext { walletService, wallet in
                wallet!.exists!.lock()
                walletService.setWallet(wallet: wallet!.exists!)
            }.dispose(in: bag)
    }
    
    private func setupTableSettigns() {
        tableSettings.appendSection("Your Accounts")
        
        tableSettings.appendSection("Settings")
        tableSettings.appendItem(
            SettingWithWordVM(title: "Current Conversion", description: "You have no chose right now 🤗", word: self.currentConversion, isEnabled: false),
            toSectionAt: 1
        )
        tableSettings.appendItem(
            SettingWithWordVM(title: "Primary Currency", description: "You still can play CryptoKitties 🥺", word: self.primaryCurrency, isEnabled: false),
            toSectionAt: 1
        )
        tableSettings.appendItem(
            SettingWithWordVM(title: "Current Language", description: "English only, deal with it 😎", word: self.currentLanguage, isEnabled: false),
            toSectionAt: 1
        )
        tableSettings.appendItem(
            SettingWithIconVM(title: "Change Password", description: "Don't use your usual password 🤔", icon: UIImage(named: "chevron")!, action: self.changePasswordAction),
            toSectionAt: 1
        )
        
        tableSettings.appendSection("Developer Tools")
        tableSettings.appendItem(
            SettingWithSwitchVM(title: "Developer Mode", description: "For dark magicians only 🦹‍♂️", key: "isDeveloperModeEnabled", settings: self.settings, switchAction: self.switchDeveloperModeAction, defaultValue: false),
            toSectionAt: 2
        )
        if settings.object(forKey: "isDeveloperModeEnabled") as? Bool == true {
            self.tableSettings.appendItem(
                SettingWithWordVM(title: "Choose Network", activeDescription: self.currentNetworkDescription, word: self.currentNetwork, isEnabled: true, action: self.changeNetworkAction),
                toSectionAt: 2
            )
        }
        
        tableSettings.appendSection("Other")
        tableSettings.appendItem(
            SettingWithIconVM(title: "About Tesseract", description: "Info about current version and company.", icon: UIImage(named: "chevron")!, action: showInfoAboutTesseractAcion),
            toSectionAt: 3
        )
        tableSettings.appendItem(
            SettingWithIconVM(title: "Logout", description: "You’ll be back 🤖", icon: UIImage(named: "logout")!, action: self.logoutAction),
            toSectionAt: 3
        )
    }
}
