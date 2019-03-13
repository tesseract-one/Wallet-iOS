//
//  MnemonicVerificationViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/15/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK

class MnemonicVerificationViewController: KeyboardScrollViewFromBoth, ModelVCProtocol {
    typealias ViewModel = MnemonicVerificationViewModel
    
    private(set) var model: ViewModel!
    
    @IBOutlet weak var mnemonicVerificationTextView: NextResponderTextView!
    @IBOutlet weak var mnemonicVerificationTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mnemonicVerificationTextViewTop: NSLayoutConstraint!
    private var mnemonicVerificationTextViewTopInitial: CGFloat = 0.0
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var skipButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mnemonicVerificationTextView.reactive.text.map { $0 ?? "" } // useless map actually, its already empty string
            .bind(to: model.mnemonicText).dispose(in: bag)
        
//        mnemonicVerificationTextView.reactive
//            .notification(.textDidBeginEditing)
//            .with(weak: mnemonicVerificationTextView) // can't write bond to textView.error
//            .observeNext { _, mnemonicVerificationTextView in
//                mnemonicVerificationTextView.error = ""
//            }.dispose(in: bag)
//        
//        model.mnemonicVerifiedSuccessfully
//            .filter { $0 != nil }
//            .with(latestFrom: model.mnemonicError)
//            .filter { $0 == false && $1 != nil }
//            .with(weak: mnemonicVerificationTextView)
//            .observeNext { mnemonicErrorTuple, mnemonicVerificationTextView in
//                mnemonicVerificationTextView.error = mnemonicErrorTuple.1!.rawValue
//            }.dispose(in: bag)
        
        let doneTap = doneButton.reactive.tap.throttle(seconds: 0.5)
        doneTap.bind(to: model.doneMnemonicVerificationAction).dispose(in: bag)
        doneTap.with(weak: view).observeNext { view in
            view.endEditing(true)
            }.dispose(in: bag)
        
        skipButton.reactive.tap.throttle(seconds: 0.5)
            .bind(to: model.skipMnemonicVerificationAction).dispose(in: bag)
        
        mnemonicVerificationTextViewTopInitial = mnemonicVerificationTextViewTop.constant
        
        setupSizes()
    }
    
    override func moveConstraints(keyboardHeight: CGFloat?) {
        super.moveConstraints(keyboardHeight: keyboardHeight)
        if keyboardHeight != nil {
            mnemonicVerificationTextViewTop.constant = 80 * UIScreen.main.scale
        } else {
            mnemonicVerificationTextViewTop.constant = mnemonicVerificationTextViewTopInitial
        }
        if UIScreen.main.bounds.height < 600 {
            if keyboardHeight != nil {
                navigationItem.largeTitleDisplayMode = .never
            } else {
                navigationItem.largeTitleDisplayMode = .always
                
            }
            UIView.animate(withDuration: 1.0) {
                self.navigationController?.navigationBar.layoutIfNeeded()
            }
        }
        
    }
}

extension MnemonicVerificationViewController {
    private func setupSizes() {
        if UIScreen.main.bounds.height < 600 {
            mnemonicVerificationTextView.isScrollEnabled = true
            mnemonicVerificationTextViewHeight.constant = 170
        } else {
            mnemonicVerificationTextView.isScrollEnabled = false
            mnemonicVerificationTextViewHeight.constant = 220
        }
    }
}

extension MnemonicVerificationViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        
        guard let password = context.get(bean: "password") as? String else {
            print("Router context don't contain password", self)
            return
        }
        guard let newWalletData = context.get(bean: "newWalletData") as? NewWalletData else {
            print("Router context don't contain newWalletData", self)
            return
        }
        
        self.model = MnemonicVerificationViewModel(password: password, newWalletData: newWalletData, walletService: appCtx.walletService)
    }
}
