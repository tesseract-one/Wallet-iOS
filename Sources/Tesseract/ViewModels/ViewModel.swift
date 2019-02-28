//
//  ViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 2/27/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit

protocol ViewModelProtocol {
  var bag: DisposeBag { get }
}

class ViewModel: ViewModelProtocol {
  let bag = DisposeBag()
  
  init() {}
}
