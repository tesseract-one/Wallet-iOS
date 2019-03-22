//
//  TermsOfServiceViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/15/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import TesSDK

class TermsOfServiceViewControllerContext: RouterContextProtocol {
    let password: String
    let newWalletData: NewWalletData?
    
    init(password: String, data: NewWalletData? = nil) {
        self.password = password
        self.newWalletData = data
    }
}

class TermsOfServiceViewController: UIViewController, ModelVCProtocol {
    typealias ViewModel = TermsOfServiceViewModel
    
    private(set) var model: ViewModel!
    
    @IBOutlet weak var blurredView: UIView!
    @IBOutlet weak var termsTextView: UITextView!
    @IBOutlet weak var acceptButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.termsOfService.bind(to: termsTextView.reactive.text)
        
        acceptButton.reactive.tap.throttle(seconds: 0.5)
            .bind(to: model.acceptTermsAction).dispose(in: bag)
        
        goToViewAction.observeNext { [weak self] name, context in
            let vc = try! self?.viewController(for: .named(name: name), context: context)
            self?.navigationController?.pushViewController(vc!, animated: true)
            }.dispose(in: bag)
        
        termsTextView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        termsTextView.setContentOffset(.zero, animated: false)
        scrollViewDidScroll(termsTextView)
    }
}

extension TermsOfServiceViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height {
            if !acceptButton.isEnabled {
                acceptButton.isEnabled = true
                acceptButton.setTitleColor(.white, for: .normal)
                acceptButton.backgroundColor = UIColor(red: 74.0 / 255.0, green: 148.0 / 255.0, blue: 227.0 / 255.0, alpha: 1.0)
            }
        }
    }
}

extension TermsOfServiceViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        let toeCtx = context.get(context: TermsOfServiceViewControllerContext.self)!
        
        if let newWalletData = toeCtx.newWalletData {
            model = TermsOfServiceFromRestoreWalletViewModel(walletService: appCtx.walletService, newWalletData: newWalletData, password: toeCtx.password, settings: appCtx.settings)
        } else {
            model = TermsOfServiceFromSignInViewModel(walletService: appCtx.walletService, password: toeCtx.password)
        }
    }
}
