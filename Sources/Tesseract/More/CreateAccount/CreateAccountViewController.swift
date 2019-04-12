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
    
    @IBOutlet weak var backButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.accountImages.bind(to: accountImagesCV, cellType: CreateAccountCollectionViewCell.self) { cell, image in
            cell.setupCell(emoji: image)
        }.dispose(in: reactive.bag)
        
        accountImagesCV.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
        accountImagesCV.reactive.selectedItemIndexPath.distinctUntilChanged().throttle(seconds: 0.1).map { $0.row }
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
        
        backButton.reactive.tap.throttle(seconds: 0.5).bind(to: goBack).dispose(in: bag)
        
        goBack.observeNext { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.dispose(in: reactive.bag)
        
        setupKeyboardDismiss()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 37/255, green: 37/255, blue: 37/255, alpha: 1.0)
        navigationController?.navigationBar.shadowRadius = 0.0
        navigationController?.navigationBar.shadowOffset = CGSize(width: 0, height: 0)
        navigationController?.navigationBar.shadowOpacity = 0
        navigationController?.navigationBar.shadowColorIB = .none
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
        navigationController?.navigationBar.shadowRadius = 4.0
        navigationController?.navigationBar.shadowOffset = CGSize(width: 0, height: 1)
        navigationController?.navigationBar.shadowOpacity = 0.25
        navigationController?.navigationBar.shadowColorIB = .black
    }

}


extension CreateAccountViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        model = CreateAccountViewModel(walletService: appCtx.walletService)
        
        model.bootstrap()
    }
}
