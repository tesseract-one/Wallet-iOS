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
    
    let wallet = Property<WalletViewModel?>(nil)
    let activeAccount = Property<Account?>(nil)
    let accounts = MutableObservableArray<Account>()
    let network = Property<UInt64>(0)
    let settings: UserDefaults
    
    let tableSettings = MutableObservableArray2D<String, ViewModel>(Array2D())
    let viewModelAccounts = MutableObservableArray<ViewModel>()
    
    let createAccountAction = SafePublishSubject<Void>()
    let currentConversion = Property<String>("USD")
    let primaryCurrency = Property<String>("ETH")
    let currentLanguage = Property<String>("ENG")
    let changePasswordAction = SafePublishSubject<Void>()
    let switchDeveloperModeAction = SafePublishSubject<Bool>()
    let currentNetwork = Property<String>("RKB")
    let currentNetworkDescription = Property<String>("Rinkeby Network")
    let changeNetworkAction = SafePublishSubject<Void>()
    let showInfoAboutTesseractAction = SafePublishSubject<Void>()
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
        
        wallet.filter { $0 != nil }
            .with(weak: self)
            .observeNext { wallet, sself in
                wallet!.accounts.bind(to: sself.accounts).dispose(in: wallet!.bag)
            }.dispose(in: bag)
        
        accounts.with(weak: self)
            .map{ accounts, sself -> [ViewModel] in
                var accountsVM: [ViewModel] = accounts.collection.map { SettingWithAccountVM(account: $0, web3Service: sself.web3Service, changeRateService: sself.changeRateService, network: sself.network) }
                let createAccountVM = ButtonWithIconVM(title: "Create Account", icon:  UIImage(named: "plus")!, action: sself.createAccountAction)
                
                accountsVM.append(createAccountVM)
                
                return accountsVM
            }
            .bind(to: viewModelAccounts)
            .dispose(in: bag)
        
        
        network.map { NETWORKS[Int($0) - 1].abbr }.bind(to: currentNetwork)
        network.map { NETWORKS[Int($0) - 1].name }.bind(to: currentNetworkDescription)
        
        switchDeveloperModeAction.with(weak: self).observeNext { isOn, sself in
            let numberOfItemsInDeveloperSection = sself.tableSettings[sectionAt: 2].items.count
            
            if !isOn && numberOfItemsInDeveloperSection > 1 {
                sself.tableSettings.removeFromSubrange(section: 2, range: 1... )
            } else if isOn && numberOfItemsInDeveloperSection == 1 {
                sself.tableSettings.appendItem(
                    SettingWithWordVM(title: "Choose Network", activeDescription: sself.currentNetworkDescription, word: sself.currentNetwork, isEnabled: true, action: sself.changeNetworkAction),
                    toSectionAt: 2
                )
            }
        }.dispose(in: bag)
        
        changeNetworkAction.map { _ in (name: "ChooseNetwork", context: nil) }
            .bind(to: goToView).dispose(in: bag)
        
        viewModelAccounts.with(weak: tableSettings).observeNext { accounts, tableSettings in
            tableSettings.removeFromSubrange(section: 0, range: ...)
            tableSettings.insert(contentsOf: accounts.collection, at: IndexPath(row: 0, section: 0))
        }.dispose(in: bag)
        
        logoutAction
            .with(weak: walletService)
            .with(latestFrom: wallet)
            .observeNext { walletService, wallet in
                wallet!.lock()
                walletService.setWallet(wallet: wallet!)
            }.dispose(in: bag)
        
        createAccountAction.map { _ in (name: "CreateAccount", context: nil) }
            .bind(to: goToView).dispose(in: bag)
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
            SettingWithIconVM(title: "About Tesseract", description: "Info about current version and company.", icon: UIImage(named: "chevron")!, action: showInfoAboutTesseractAction),
            toSectionAt: 3
        )
        tableSettings.appendItem(
            SettingWithIconVM(title: "Logout", description: "You’ll be back 🤖", icon: UIImage(named: "logout")!, action: self.logoutAction),
            toSectionAt: 3
        )
    }
}
