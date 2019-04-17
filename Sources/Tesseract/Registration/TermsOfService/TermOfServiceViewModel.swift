//
//  TermOfServiceViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit


class TermsOfServiceViewModel: ViewModel, ForwardRoutableViewModelProtocol {
    let acceptTermsAction = SafePublishSubject<Void>()
  
    let goToView = SafePublishSubject<ToView>()
    
    let errors = SafePublishSubject<Swift.Error>()
}


class TermsOfServiceFromSignInViewModel: TermsOfServiceViewModel {
    
    let walletService: WalletService
    
    init(walletService: WalletService, password: String) {
        self.walletService = walletService
        
        super.init()
        
        acceptTermsAction
            .with(weak: walletService)
            .tryMap { _, walletService in
                try walletService.createWalletData(password: password)
            }
            .pourError(into: errors)
            .map { NewWalletData in
                let context = DictionaryRouterContext(dictionaryLiteral: ("newWalletData", NewWalletData))
                return (name: "Mnemonic", context: context)
            }.bind(to: goToView).dispose(in: bag)
      }
}

class TermsOfServiceFromWalletTypeViewModel: TermsOfServiceViewModel {
    
    let wasCreatedByMetamask: Bool
    
    init (wasCreatedByMetamask: Bool) {
        self.wasCreatedByMetamask = wasCreatedByMetamask
        
        super.init()
        
        acceptTermsAction.map { _ in (name: "RestoreWallet", context: nil) }.bind(to: goToView).dispose(in: bag)
    }
}
