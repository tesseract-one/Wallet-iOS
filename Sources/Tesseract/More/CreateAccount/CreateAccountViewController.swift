//
//  CreateAccountViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import MaterialTextField
import ReactiveKit
import Bond

class CreateAccountViewController: UIViewController, ModelVCProtocol {
    typealias ViewModel = CreateAccountViewModel
    
    var model: ViewModel!
    
    @IBOutlet weak var accountNameTF: MFTextField!
    @IBOutlet weak var accountImagesCV: UICollectionView!
    @IBOutlet weak var createAccountButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.accountImages.bind(to: accountImagesCV, cellType: CreateAccountCollectionViewCell.self) { cell, image in
            cell.setupCell(emoji: image)
        }.dispose(in: reactive.bag)
        
        accountImagesCV.reactive.selectedItemIndexPath.distinct().throttle(seconds: 0.1).map { $0.row }
            .bind(to: model.accountEmojiIndex).dispose(in: reactive.bag)
        
        createAccountButton.reactive.tap.throttle(seconds: 0.5)
            .bind(to: model.createAccountAction).dispose(in: reactive.bag)
        
        accountNameTF.reactive.controlEvents(.editingDidBegin).map { _ in "" }
            .bind(to: accountNameTF.reactive.error).dispose(in: reactive.bag)
        accountNameTF.reactive.controlEvents(.editingDidBegin).map { _ in nil }
            .bind(to: model.validationError).dispose(in: reactive.bag)
        
        accountNameTF.reactive.text.map { $0 ?? "" }
            .bind(to: model.accountName).dispose(in: reactive.bag)
        
        model.validationError.filter { $0 != nil }
            .bind(to: accountNameTF.reactive.error).dispose(in: reactive.bag)
        
        goBack.observeNext { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.dispose(in: reactive.bag)
        
//        setupKeyboardDismiss()
    }
}


extension CreateAccountViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        model = CreateAccountViewModel(walletService: appCtx.walletService)
        
        model.bootstrap()
    }
}
