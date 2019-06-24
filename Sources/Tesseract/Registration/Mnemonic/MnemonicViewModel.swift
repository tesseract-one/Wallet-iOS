//
//  MnemonicViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit

class MnemonicViewModel: ViewModel, ForwardRoutableViewModelProtocol {
    let doneMnemonicAction = PassthroughSubject<Void, Never>()
    let mnemonicProp = Property<String>("")
    
    let notificationNode = PassthroughSubject<NotificationProtocol, Never>()
    
    let goToView = PassthroughSubject<ToView, Never>()
    
    init (mnemonic: String) {
        super.init()
        
        mnemonicProp.send(mnemonic)
        
        doneMnemonicAction.map { _ in (name: "MnemonicVerification", context: nil) }
            .bind(to: goToView).dispose(in: bag)
    }
}
