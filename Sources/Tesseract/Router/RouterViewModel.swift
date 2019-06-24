//
//  RouterVM.swift
//  Tesseract
//
//  Created by Yehor Popovych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit

protocol ForwardRoutableViewModelProtocol: ViewModelProtocol {
    typealias ToView = (name: String, context: RouterContextProtocol?)
    
    var goToView: PassthroughSubject<ToView, Never> { get }
}

protocol BackRoutableViewModelProtocol: ViewModelProtocol {
    var goBack: PassthroughSubject<Void, Never> { get }
}

typealias RoutableViewModelProtocol = BackRoutableViewModelProtocol & ForwardRoutableViewModelProtocol

protocol ModelVCProtocol: RouterViewProtocol {
    associatedtype ViewModel
    
    var model: ViewModel! { get }
}

extension ModelVCProtocol where Self: UIViewController, Self.ViewModel: ForwardRoutableViewModelProtocol {
    var goToViewAction: PassthroughSubject<ViewModel.ToView, Never> {
        return model.goToView
    }
}

extension ModelVCProtocol where Self: UIViewController, Self.ViewModel: BackRoutableViewModelProtocol {
    var goBack: PassthroughSubject<Void, Never> {
        return model.goBack
    }
}
