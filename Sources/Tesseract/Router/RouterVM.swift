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
    typealias Route = (name: String, context: RouterContextProtocol?)
    
    var goToView: SafePublishSubject<Route> { get }
}

protocol BackRoutableViewModelProtocol: ViewModelProtocol {
    var goBack: SafePublishSubject<Void> { get }
}

typealias RoutableViewModelProtocol = BackRoutableViewModelProtocol & ForwardRoutableViewModelProtocol

protocol ModelVCProtocol: RouterViewProtocol {
    associatedtype ViewModel: ViewModelProtocol
    
    var model: ViewModel { get }
}

extension ModelVCProtocol where Self: UIViewController, Self.ViewModel: ForwardRoutableViewModelProtocol {
    var goToViewAction: SafePublishSubject<ViewModel.Route> {
        return model.goToView
    }
}

extension ModelVCProtocol where Self: UIViewController, Self.ViewModel: BackRoutableViewModelProtocol {
    var goBack: SafePublishSubject<Void> {
        return model.goBack
    }
}
