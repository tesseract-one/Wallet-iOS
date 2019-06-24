//
//  ChooseNetworkViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/29/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class ChooseNetworkViewModel: ViewModel {
    let settings: Settings
    let network = Property<UInt64>(0)
    
    let networks = MutableObservableArray<NetworkType>()
    
    let changeNetworkAction = PassthroughSubject<UInt64, Never>()
    
    init(settings: Settings) {
        self.settings = settings
        super.init()
    }
    
    func bootstrap() {
        networks.replace(with: NETWORKS)
        
        let settings = self.settings
        changeNetworkAction
            .observeNext { network in
                settings.set(network, forKey: .ethereumNetwork)
            }.dispose(in: bag)
        
        changeNetworkAction.bind(to: network).dispose(in: bag)
    }
}
