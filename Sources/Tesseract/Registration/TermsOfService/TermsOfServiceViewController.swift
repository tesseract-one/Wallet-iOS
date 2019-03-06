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
import Mnemonic

//class TermsOfServiceViewControllerContext: RouterContextProtocol {
//    var password: String = ""
//    var newWalletData: NewWalletData?
//
//    init() {
//        self.password = self.get(bean: "password") as! String
//        self.newWalletData = self.get(bean: "newWalletData") as? NewWalletData
//    }
//}

class TermsOfServiceViewController: UIViewController, ModelVCProtocol {
  typealias ViewModel = TermsOfServiceViewModel
  
  private(set) var model: ViewModel!
  
  // MARK: Outlets
  @IBOutlet weak var termsTextView: UITextView!
  @IBOutlet weak var acceptButton: UIButton!
  
  // MARK: Lifecycle hooks
  override func viewDidLoad() {
    super.viewDidLoad()
    
    model.termsOfService.bind(to: termsTextView.reactive.text)
    
    acceptButton.reactive.tap.throttle(seconds: 0.5)
      .bind(to: model.acceptTermsAction).dispose(in: bag)
    
    goToViewAction.observeNext { [weak self] name, context in
      let vc = try! self?.viewController(for: .named(name: name), context: context)
      self?.navigationController?.pushViewController(vc!, animated: true)
    }.dispose(in: bag)
  }
  
  override func viewDidLayoutSubviews() {
    termsTextView.setContentOffset(.zero, animated: false)
  }
}

extension TermsOfServiceViewController: ContextSubject {
  func apply(context: RouterContextProtocol) {
    let appCtx = context.get(context: ApplicationContext.self)!
//    let toeCtx = TermsOfServiceViewControllerContext()

    if let newWalletData = context.get(bean: "newWalletData") as? NewWalletData {
        guard let password = context.get(bean: "password") as? String else {
            print("Router context don't contain newWalletData", self)
            return
        }
        model = TermsOfServiceFromRestoreWalletViewModel(walletService: appCtx.walletService, newWalletData: newWalletData, password: password)
    } else {
        model = TermsOfServiceFromSignInViewModel(walletService: appCtx.walletService)
    }
  }
}
