//
//  EthereumKeychainViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import OpenWallet


protocol EthereumKeychainViewControllerBaseControls  {
    var acceptButton: UIButton! { get set }
    var fingerButton: UIButton! { get set }
    var passwordField: MaterialTextField! { get set }
    
    var acceptBtnRightConstraint: NSLayoutConstraint! { get set }
    var bottomConstraint: NSLayoutConstraint! { get set }
}

private let NETWORK_NAMES: Dictionary<UInt64, String> = [
    1: "Main Ethereum Network",
    2: "Ropsten Test Network",
    3: "Kovan Test Network",
    4: "Rinkeby Test Network"
]

class EthereumKeychainViewController<Request: EthereumRequestMessageProtocol>: ExtensionViewController {
    var responseCb: ((Swift.Result<Request.Response, OpenWalletError>) -> Void)!
    var request: Request!
    
    let runWalletOperation = SafePublishSubject<Void>()
    let passwordErrorSiganl = SafePublishSubject<Swift.Error>()
    
    private var _passwordField: MaterialTextField {
        return (self as! EthereumKeychainViewControllerBaseControls).passwordField
    }
    
    private var _acceptButton: UIButton {
        return (self as! EthereumKeychainViewControllerBaseControls).acceptButton
    }
    
    private var _fingerButton: UIButton {
        return (self as! EthereumKeychainViewControllerBaseControls).fingerButton
    }
    
    private var _acceptBtnRightConstraint: NSLayoutConstraint {
        return (self as! EthereumKeychainViewControllerBaseControls).acceptBtnRightConstraint
    }
    
    private var _bottomConstraint: NSLayoutConstraint {
        return (self as! EthereumKeychainViewControllerBaseControls).bottomConstraint
    }
    
    private var _bottomConstraintInitial: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subTitle = NETWORK_NAMES[request.networkId] ?? "Unknown Ethereum Network"
        
        _passwordField.reactive.controlEvents(.editingDidBegin).map{ _ in "" }
            .bind(to: _passwordField.reactive.error).dispose(in: reactive.bag)
        
        passwordErrorSiganl.map { _ in "Incorrect password" }
            .bind(to: _passwordField.reactive.error).dispose(in: reactive.bag)
        
        _bottomConstraintInitial = _bottomConstraint.constant
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardOpened), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardClosed), name: UIResponder.keyboardWillHideNotification, object: nil);
        
        setupAcceptButton()
        setupFingerButton()
        setupKeyboardDismiss()
    }
    
    private func setupAcceptButton() {
        let acceptTap = _acceptButton.reactive.tap.throttle(seconds: 0.5)
            
        acceptTap.with(latestFrom: _passwordField.reactive.text)
            .map{$0.1 ?? ""}
            .with(weak: context.walletService)
            .tryMap { password, service in
                try service.unlockWallet(password: password)
            }
            .pourError(into: passwordErrorSiganl)
            .bind(to: runWalletOperation)
            .dispose(in: reactive.bag)
        
        acceptTap.with(weak: view)
            .observeNext { view in
                view.endEditing(true)
            }
            .dispose(in: bag)
    }
    
    private func setupFingerButton() {
        if (context.settings.number(forKey: .isBiometricEnabled) as? Bool == true) &&
           (context.passwordService.getBiometricType() != .none) {
            _fingerButton.isHidden = false
            _acceptBtnRightConstraint.constant = 74
        } else {
            _fingerButton.isHidden = true
            _acceptBtnRightConstraint.constant = 16
        }
        
        _fingerButton.reactive.tap.throttle(seconds: 0.5)
            .with(weak: context.passwordService)
            .flatMapLatest { passwordService in
                passwordService.canLoadPassword().signal
            }
            .suppressedErrors
            .filter { $0 == true }
            .map { _ in }
            .with(weak: context.passwordService)
            .flatMapLatest { passwordService in
                passwordService.loadPasswordWithBiometrics().signal
            }
            .suppressedErrors
            .with(weak: context.walletService)
            .tryMap { password, service in
                try service.unlockWallet(password: password)
            }
            .pourError(into: passwordErrorSiganl)
            .bind(to: runWalletOperation)
            .dispose(in: reactive.bag)
    }
    
    func moveConstraints(keyboardHeight: CGFloat?) {
        if let height = keyboardHeight {
            self._bottomConstraint.constant = self._bottomConstraintInitial + height
        } else {
            self._bottomConstraint.constant = self._bottomConstraintInitial
        }
    }
    
    @objc func onKeyboardOpened(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.layoutIfNeeded()
            moveConstraints(keyboardHeight: keyboardHeight)
            UIView.animate(withDuration: 1.0) {
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    @objc func onKeyboardClosed(notification: NSNotification) {
        self.view.layoutIfNeeded()
        moveConstraints(keyboardHeight: nil)
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func fail(error: OpenWalletError) {
        responseCb(.failure(error))
    }
    
    func succeed(response: Request.Response) {
        responseCb(.success(response))
    }
}
