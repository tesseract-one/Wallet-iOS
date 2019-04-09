//
//  MnemonicViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/15/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import Wallet
import ReactiveKit
import Bond
import Foundation

class MnemonicViewController: UIViewController, ModelVCProtocol {
  typealias ViewModel = MnemonicViewModel
  
  private(set) var model: ViewModel!

  @IBOutlet weak var mnemonicLabel: UILabel!
  @IBOutlet weak var doneButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    model.mnemonicProp.bind(to: mnemonicLabel.reactive.text).dispose(in: bag)
    
    doneButton.reactive.tap.throttle(seconds: 0.5)
      .bind(to: model.doneMnemonicAction).dispose(in: bag)
    
    mnemonicLabel.reactive.tapGesture().throttle(seconds: 0.5)
        .map { _ in }
        .bind(to: model.copyAction)
        .dispose(in: reactive.bag)
    
    goToViewAction.observeNext { [weak self] name, context in
      let vc = try! self?.viewController(for: .named(name: name), context: context)
      self?.navigationController?.pushViewController(vc!, animated: true)
    }.dispose(in: bag)
  }
}

extension MnemonicViewController: ContextSubject {
  func apply(context: RouterContextProtocol) {
    let appCtx = context.get(context: ApplicationContext.self)!
    
    guard let newWalletData = context.get(bean: "newWalletData") as? NewWalletData else {
      print("Router context don't contain newWalletData", self)
      return
    }

    let model = MnemonicViewModel(mnemonic: newWalletData.mnemonic)
    
    model.notificationNode.bind(to: appCtx.notificationNode).dispose(in: model.bag)
    
    self.model = model
  }
}
