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
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.mnemonicProp.bind(to: mnemonicLabel.reactive.text).dispose(in: bag)
        
        doneButton.reactive.tap.throttle(seconds: 0.5)
            .bind(to: model.doneMnemonicAction).dispose(in: reactive.bag)
        
        goToViewAction.observeNext { [weak self] name, context in
            let vc = try! self?.viewController(for: .named(name: name), context: context)
            self?.navigationController?.pushViewController(vc!, animated: true)
        }.dispose(in: reactive.bag)
        
        backButton.reactive.tap.throttle(seconds: 0.5)
            .observeNext { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }.dispose(in: reactive.bag)
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
