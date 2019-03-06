//
//  RestoreViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/6/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class RestoreWalletViewController: UIViewController, ModelVCProtocol {
    typealias ViewModel = RestoreWalletViewModel
    
    private(set) var model: ViewModel!
    
    // MARK: Outlets
    //
    @IBOutlet weak var mnemonicTextView: UITextView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: NextResponderTextField!
    @IBOutlet weak var restoreButton: UIButton!
    
    // MARK: Lifecycle hooks
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mnemonicTextView.reactive.text.map { $0 ?? "" }
            .bind(to: model.mnemonic)
        passwordField.reactive.text.map { $0 ?? "" }
            .bind(to: model.password).dispose(in: bag)
        confirmPasswordField.reactive.text.map { $0 ?? "" }
            .bind(to: model.confirmPassword).dispose(in: bag)
        
        passwordField.reactive.controlEvents(.editingDidBegin)
            .merge(with: confirmPasswordField.reactive.controlEvents(.editingDidBegin))
            .map { _ in "" }
            .bind(to: confirmPasswordField.reactive.error)
            .dispose(in: bag)
        
        mnemonicTextView.reactive.tapGesture()
            .map { _ in "" }
            .bind(to: confirmPasswordField.reactive.error)
            .dispose(in: bag)
        
        let restoreTap = restoreButton.reactive.tap.throttle(seconds: 0.5)
        restoreTap.bind(to: model.restoreAction).dispose(in: bag)
        restoreTap.with(weak: view).observeNext { view in
            view.endEditing(true)
        }.dispose(in: bag)
        
        let restoreWalletSuccessfull = model.restoreWalletSuccessfully
            .filter { $0 != nil }
            .with(latestFrom: model.restoreFormError)
            .filter { $0 != true && $1 != nil }
        
        restoreWalletSuccessfull
            .map { $1!.rawValue }
            .bind(to: confirmPasswordField.reactive.error)
            .dispose(in: bag)
        restoreWalletSuccessfull
            .map { _ in "" }
            .bind(to: mnemonicTextView.reactive.text)
            .dispose(in: bag)
        restoreWalletSuccessfull
            .map { _ in "" }
            .bind(to: passwordField.reactive.text)
            .dispose(in: bag)
        restoreWalletSuccessfull
            .map { _ in "" }
            .bind(to: confirmPasswordField.reactive.text)
            .dispose(in: bag)
        
        goToViewAction.observeNext { [weak self] name, context in
            let vc = try! self?.viewController(for: .named(name: name), context: context)
            self?.navigationController?.pushViewController(vc!, animated: true)
        }.dispose(in: bag)
    }

    // MARK: Default values
    // Make the Status Bar Light/Dark Content for this View
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

extension RestoreWalletViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        model = RestoreWalletViewModel(walletService: appCtx.walletService)
    }
}

