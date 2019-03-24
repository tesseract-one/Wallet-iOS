//
//  SignInViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/21/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class SignInViewController: KeyboardScrollView, ModelVCProtocol {
    typealias ViewModel = SignInViewModel
    
    private(set) var model: ViewModel!
    
    @IBOutlet weak var passwordField: NextResponderTextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signInButtonRight: NSLayoutConstraint!
    @IBOutlet weak var fingerButton: UIButton!
    @IBOutlet weak var restoreKeyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordField.reactive.text.map { $0 ?? "" }
            .bind(to: model.password).dispose(in: bag)
        passwordField.reactive.controlEvents(.editingDidBegin)
            .map { _ in "" }
            .bind(to: passwordField.reactive.error)
            .dispose(in: bag)
        
        let signInTap = signInButton.reactive.tap.throttle(seconds: 0.5)
        signInTap.bind(to: model.signInAction).dispose(in: bag)
        signInTap.with(weak: view).observeNext { view in
            view.endEditing(true)
        }.dispose(in: bag)
        
        let restoreKeyTap = restoreKeyButton.reactive.tap.throttle(seconds: 0.5)
        restoreKeyTap.bind(to: model.restoreKeyAction).dispose(in: bag)
        restoreKeyTap.with(weak: view).observeNext { view in
            view.endEditing(true)
        }.dispose(in: bag)
        
        let signInUnsuccessfull = model.signInSuccessfully
            .filter { $0 != nil }
            .with(latestFrom: model.passwordError)
            .filter { $0 == false && $1 != nil }
        
        signInUnsuccessfull
            .map { $1!.rawValue }
            .bind(to: passwordField.reactive.error)
            .dispose(in: bag)
        signInUnsuccessfull
            .map { _ in "" }
            .bind(to: passwordField.reactive.text)
            .dispose(in: bag)
        
        model.showTouchIdPopup.with(weak: self).observeNext{ sself in
            sself.showTouchIdPopup()
        }
        .dispose(in: bag)
        
        goToViewAction.observeNext { [weak self] name, context in
            let vc = try! self?.viewController(for: .named(name: name), context: context)
            self?.navigationController?.pushViewController(vc!, animated: true)
        }.dispose(in: bag)
        
        navigationController?.isToolbarHidden = true
        
        setupFingerButton()
        setupKeyboardDismiss()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    private func showTouchIdPopup() {
        let alert = UIAlertController(title: "Do you wan't \u{22}\(Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String)\u{22} to use Touch ID", message: "as password", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { [weak self] _ in
            self?.model.touchIdPopupAnswer.next(true)
        }))
        alert.addAction(UIAlertAction(title: "Don't Allow", style: UIAlertAction.Style.cancel, handler: { [weak self] _ in
            self?.model.touchIdPopupAnswer.next(false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setupFingerButton() {
        model.isBiometricEnabled.map { !$0 }.bind(to: fingerButton.reactive.isHidden).dispose(in: bag)
        
        model.isBiometricEnabled.with(weak: signInButtonRight)
            .observeNext { isEnabled, signInButtonRight in
                signInButtonRight.constant = isEnabled ? 82 : 16
            }.dispose(in: bag)
        
        fingerButton.reactive.tap.throttle(seconds: 0.5)
            .bind(to: model.fingerAction).dispose(in: bag)
    }
}

extension SignInViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        self.model = SignInViewModel(walletService: appCtx.walletService, passwordService: appCtx.passwordService, settings: appCtx.settings )
    }
}
