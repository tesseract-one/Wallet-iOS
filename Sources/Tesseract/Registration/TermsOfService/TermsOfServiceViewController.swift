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
    
    acceptButton.reactive.tap.bind(to: model.acceptTermsAction).dispose(in: bag)
    
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
//    guard let mnemonic = context.get(bean: "mnemonic") as? String else {
//      print("Router context don't contain mnemonic", self)
//      return
//    }
//    guard let wallet = context.get(bean: "wallet") as? Wallet else {
//      print("Router context don't contain mnemonic", self)
//      return
//    }
//    self.model = TermsOfServiceViewModel(mnemonic: mnemonic, wallet: wallet)
    self.model = TermsOfServiceViewModel()
  }
}
