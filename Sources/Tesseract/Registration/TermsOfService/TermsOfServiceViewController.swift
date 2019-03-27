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
    let password: String?
    let wasCreatedByMetamask: Bool?
    
    init(password: String? = nil, wasCreatedByMetamask: Bool? = nil) {
        self.password = password
        self.wasCreatedByMetamask = wasCreatedByMetamask
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // kludge to fix large title in navigation bar of next screen, when navigation bar on current screen is small (after scrolling)
        termsTextView.setContentOffset(.zero, animated: false)
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
        
        if let wasCreatedByMetamask = toeCtx.wasCreatedByMetamask {
            model = TermsOfServiceFromWalletTypeViewModel(wasCreatedByMetamask: wasCreatedByMetamask)
        } else if let password = toeCtx.password {
            model = TermsOfServiceFromSignInViewModel(walletService: appCtx.walletService, password: password)
        }
    }
}
