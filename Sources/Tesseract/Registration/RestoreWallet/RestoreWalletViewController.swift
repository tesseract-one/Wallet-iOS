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

class RestoreWalletViewController: KeyboardAutoScrollViewController, ModelVCProtocol {
    typealias ViewModel = RestoreWalletViewModel
    
    private(set) var model: ViewModel!
    
    @IBOutlet weak var mnemonicTextView: TextView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: NextResponderTextField!
    @IBOutlet weak var restoreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mnemonicTextView.reactive.notification(.textDidChange).map { $0.text ?? "" }
            .bind(to: model.mnemonic)
        passwordField.reactive.text.map { $0 ?? "" }
            .bind(to: model.password).dispose(in: bag)
        confirmPasswordField.reactive.text.map { $0 ?? "" }
            .bind(to: model.confirmPassword).dispose(in: bag)
        
        let beginEditingPasswordField = passwordField.reactive.controlEvents(.editingDidBegin)
            .merge(with: confirmPasswordField.reactive.controlEvents(.editingDidBegin))
            .map { _ in "" }
        let beginEditingMnemonicField = mnemonicTextView.reactive
            .notification(.textDidBeginEditing)
            .map { _ in "" }
        let beginEditingField = beginEditingMnemonicField.merge(with: beginEditingPasswordField)
        beginEditingField.bind(to: confirmPasswordField.reactive.error).dispose(in: bag)
        beginEditingField.bind(to: mnemonicTextView.reactive.error).dispose(in: bag)
        
        let restoreTap = restoreButton.reactive.tap.throttle(seconds: 0.5)
        restoreTap.bind(to: model.restoreAction).dispose(in: bag)
        restoreTap.with(weak: view).observeNext { view in
            view.endEditing(true)
        }.dispose(in: bag)
        
        let restoreWalletUnsuccessfull = model.restoreWalletSuccessfully.filter { $0 != nil }
        
        let passwordErrors = restoreWalletUnsuccessfull
            .with(latestFrom: model.passwordError)
            .filter { $0 != true && $1 != nil }
        passwordErrors
            .map { $1!.rawValue }
            .bind(to: confirmPasswordField.reactive.error)
            .dispose(in: bag)
        passwordErrors
            .map { _ in "" }
            .bind(to: passwordField.reactive.text)
            .dispose(in: bag)
        passwordErrors
            .map { _ in "" }
            .bind(to: confirmPasswordField.reactive.text)
            .dispose(in: bag)
        
        restoreWalletUnsuccessfull
            .with(latestFrom: model.mnemonicError)
            .filter { $0 != true && $1 != nil }
            .map { $1!.rawValue}
            .bind(to: mnemonicTextView.reactive.error)
            .dispose(in: bag)
        
        setupSizes()
        setupKeyboardDismiss()
    }
}

extension RestoreWalletViewController {
    private func setupSizes() {
        mnemonicTextView.frame.size.height = 110
    }
}

extension RestoreWalletViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        
        guard let wasCreatedByMetamask = context.get(bean: "wasCreatedByMetamask") as? Bool else {
            print("Router context don't contain wasCreatedByMetamask", self)
            return
        }
        
        model = RestoreWalletViewModel(walletService: appCtx.walletService, settings: appCtx.settings, wasCreatedByMetamask: wasCreatedByMetamask)
    }
}

