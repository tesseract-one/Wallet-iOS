//
//  MnemonicViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit

class MnemonicViewModel: ViewModel, ForwardRoutableViewModelProtocol {
  let doneMnemonicAction = SafePublishSubject<Void>()
  let mnemonicProp = Property<String>("")
  
  let goToView = SafePublishSubject<ToView>()
  
  init (mnemonic: String) {
    super.init()
    
    print("mnemonic", mnemonic)
    mnemonicProp.next(mnemonic)
    
    doneMnemonicAction.map { _ in (name: "MnemonicVerification", context: nil) }
      .bind(to: goToView).dispose(in: bag)
  }
}
