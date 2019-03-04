//
//  TermOfServiceViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import TesSDK

class TermsOfServiceViewModel: ViewModel, ForwardRoutableViewModelProtocol {
  let acceptTermsAction = SafePublishSubject<Void>()
  let termsOfService = Property<String>("")
  
  let goToView = SafePublishSubject<ToView>()
  
  private let walletService: WalletService
  
  init (walletService: WalletService) {
    self.walletService = walletService
    
    super.init()
    
    let terms = "When someone does something that they know that they shouldn’t do, did they really have a choice. Maybe what I mean to say is did they really have a chance. You can take two people, present them with the same fork in the road, and one is going to have an easier time than the other choosing the right path.\nIs there such a thing as the right path? You could argue back and forth with God and Evolution and such topics. The side that you take in an arguement like that might lead you to think that you know the meaning to life. How can we really know though. At least up until now there isn’t and 100% proof to either side. If God was a gaurantee – why would he leave so many of us here to die, without the information or say it as proof that we individually would have needed to make that choice?"

    termsOfService.next(terms)

    setupTermsAccept()
  }
}

extension TermsOfServiceViewModel {
  private func setupTermsAccept() {

    acceptTermsAction
      .with(weak: walletService)
      .flatMapLatest { _, walletService in
        walletService.createWalletData().signal
      }
      .suppressError(logging: true)
      .map { NewWalletData in
        let context = DictionaryRouterContext(dictionaryLiteral: ("newWalletData", NewWalletData))
        return (name: "Mnemonic", context: context)
      }.bind(to: goToView).dispose(in: bag)
  }
}
