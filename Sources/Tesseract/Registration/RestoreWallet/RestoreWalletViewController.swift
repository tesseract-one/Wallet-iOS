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
    
    @IBOutlet weak var descreptionLabel: UILabel!
    @IBOutlet weak var mnemonicTextViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var wasCreatedByMetamaskView: UIView!
    @IBOutlet weak var wasCreatedByMetamaskLabel: UILabel!
    @IBOutlet weak var wasCreatedByMetamaskButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mnemonicTextView.reactive.notification(.textDidChange).map { $0.text ?? "" }
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
        
        mnemonicTextView.reactive
            .notification(.textDidBeginEditing)
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
        
        setupSizes()
        setupWasCreatedByMnemonic()
        setupKeyboardDismiss()
    }
}

extension RestoreWalletViewController {
    private func setupSizes() {
        mnemonicTextView.frame.size.height = 110
        
        if UIScreen.main.bounds.height < 600 {
            descreptionLabel.removeFromSuperview()
            mnemonicTextViewTopConstraint.constant = 24
        }
    }
}

extension RestoreWalletViewController {
    private func setupWasCreatedByMnemonic() {
        wasCreatedByMetamaskButton.setImage(UIImage(named: "checked-box-icon"), for: .selected)
        wasCreatedByMetamaskButton.setImage(UIImage(named: "unchecked-box-icon"), for: .normal)
        
        wasCreatedByMetamaskView.reactive.tapGesture().throttle(seconds: 0.3)
            .with(latestFrom: model.wasCreatedByMetamask)
            .map { !$0.1 }
            .bind(to: model.wasCreatedByMetamask)
            .dispose(in: reactive.bag)
        
        model.wasCreatedByMetamask.bind(to: wasCreatedByMetamaskButton.reactive.isSelected).dispose(in: reactive.bag)
        model.wasCreatedByMetamask.with(weak: wasCreatedByMetamaskLabel)
            .observeNext { wasCreatedByMetamask, wasCreatedByMetamaskLabel in
                wasCreatedByMetamaskLabel.alpha = wasCreatedByMetamask ? 1.0 : 0.3
            }
            .dispose(in: reactive.bag)
    }
}


extension RestoreWalletViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        model = RestoreWalletViewModel(walletService: appCtx.walletService)
    }
}

