//
//  MnemonicViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/15/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK

class MnemonicViewController: UIViewController, ModelVCProtocol {
  typealias ViewModel = MnemonicViewModel
  
  private(set) var model: ViewModel!

  // MARK: Outlets
  //
  @IBOutlet weak var mnemonicTextView: UITextView!
  @IBOutlet weak var doneButton: UIButton!

  // MARK: Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    
    model.mnemonicProp.bind(to: mnemonicTextView.reactive.text).dispose(in: bag)
    
    doneButton.reactive.tap.throttle(seconds: 0.5)
      .bind(to: model.doneMnemonicAction).dispose(in: bag)
    
    goToViewAction.observeNext { [weak self] name, context in
      let vc = try! self?.viewController(for: .named(name: name), context: context)
      self?.navigationController?.pushViewController(vc!, animated: true)
      }.dispose(in: bag)
  }
}

extension MnemonicViewController: ContextSubject {
  func apply(context: RouterContextProtocol) {
    guard let newWalletData = context.get(bean: "newWalletData") as? NewWalletData else {
      print("Router context don't contain newWalletData", self)
      return
    }

    self.model = MnemonicViewModel(mnemonic: newWalletData.mnemonic)
  }
}
