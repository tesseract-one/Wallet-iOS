//
//  TermsOfServiceViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/15/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit

class TermsOfServiceViewController: UIViewController, ModelVCProtocol {
  typealias ViewModel = TermsOfServiceViewModel
  
  private(set) var model: ViewModel!
  
  // MARK: Outlets
  @IBOutlet weak var termsTextView: UITextView!
  @IBOutlet weak var acceptButton: UIButton!
  
  // MARK: Lifecycle hooks
  //
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
    
    model = TermsOfServiceViewModel(walletService: appCtx.walletService)
    
    model.errors.bind(to: appCtx.errorNode).dispose(in: model.bag)
  }
}
