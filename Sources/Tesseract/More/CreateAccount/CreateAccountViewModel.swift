//
//  CreateAccountViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond

class CreateAccountViewModel: ViewModel {
    let accountImages = MutableObservableArray<String>()
    
    override init() {
        super.init()
    }
    
    func bootstrap() {
        accountImages.replace(with: ["👨🏼‍💻", "👩🏿‍🎤", "👯‍♀️", "🦄", "😈", "💩", "👾", "🦹‍♀️"])
    }
}
