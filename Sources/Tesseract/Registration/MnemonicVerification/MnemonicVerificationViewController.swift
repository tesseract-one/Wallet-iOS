//
//  MnemonicVerificationViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/15/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK

class MnemonicVerificationViewController: UIViewController, ModelVCProtocol {
  typealias ViewModel = MnemonicVerificationViewModel
  
  private(set) var model: ViewModel!
 
  // MARK: Outlets
  //
  @IBOutlet weak var mnemonicVerificationTextView: NextResponderTextView!
  @IBOutlet weak var doneButton: UIButton!
  
  // MARK: Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mnemonicVerificationTextView.reactive.text.map { $0 ?? "" } // useless map actually, its already empty string
      .bind(to: model.mnemonicText).dispose(in: bag)
    
    mnemonicVerificationTextView.reactive.text
      .with(weak: mnemonicVerificationTextView) // can't write bond to textView.error
      .observeNext { _, mnemonicVerificationTextView in
        mnemonicVerificationTextView.error = ""
      }.dispose(in: bag)

    let mnemonicVerifiedSuccessfull =
      model.mnemonicVerifiedSuccessfully
        .filter { $0 != nil }
        .with(latestFrom: model.mnemonicError)
        .filter { $0 == false && $1 != nil }
    
    mnemonicVerifiedSuccessfull
      .with(weak: mnemonicVerificationTextView)
      .observeNext { mnemonicErrorTuple, mnemonicVerificationTextView in
        mnemonicVerificationTextView.error = mnemonicErrorTuple.1?.rawValue
      }.dispose(in: bag)
    
    doneButton.reactive.tap.bind(to: model.doneMnemonicVerificationAction).dispose(in: bag)
    doneButton.reactive.tap.with(weak: view).observeNext { view in
      view.endEditing(true)
    }.dispose(in: bag)
  }
}

extension MnemonicVerificationViewController: ContextSubject {
  func apply(context: RouterContextProtocol) {
    let appCtx = context.get(context: ApplicationContext.self)!

    guard let mnemonic = context.get(bean: "mnemonic") as? String else {
      print("Router context don't contain mnemonic", self)
      return
    }
    guard let wallet = context.get(bean: "wallet") as? Wallet else {
      print("Router context don't contain wallet", self)
      return
    }
    
    self.model = MnemonicVerificationViewModel(mnemonic: mnemonic, wallet: wallet, walletService: appCtx.walletService)
  }
}
