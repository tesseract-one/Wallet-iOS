//
//  WalletTypeViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/27/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond

enum SeedType: String, Equatable {
    case Tesseract
    case Metamask
}

class WalletTypeViewModel: ViewModel, ForwardRoutableViewModelProtocol {
    let chooseSeedAction = SafePublishSubject<SeedType?>()
    
    let goToView = SafePublishSubject<ToView>()

    override init () {
        super.init()
        
        chooseSeedAction.filter { $0 != nil }
            .map { seedType in
                let wasCreatedByMetamask = seedType! == .Metamask
                let context = TermsOfServiceViewControllerContext(wasCreatedByMetamask: wasCreatedByMetamask)
                return (name: "TermsOfService", context: context)
            }
            .bind(to: goToView)
            .dispose(in: bag)
    }
}
