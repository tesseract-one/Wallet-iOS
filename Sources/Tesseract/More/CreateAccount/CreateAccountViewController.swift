//
//  CreateAccountViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class CreateAccountViewController: UIViewController, ModelVCProtocol {
    typealias ViewModel = CreateAccountViewModel
    
    var model: ViewModel!
    
    @IBOutlet weak var accountNameTF: UITextField!
    @IBOutlet weak var accountImagesCV: UICollectionView!
    @IBOutlet weak var createAccountButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        model.accountImages.bind(to: accountImagesCV, cellType: CreateAccountCollectionViewCell.self) { cell, image in
//            cell.setupCell(emoji: image)
//        }.dispose(in: reactive.bag)
//        
        
        setupKeyboardDismiss()
    }
}

extension CreateAccountViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
//        let appCtx = context.get(context: ApplicationContext.self)!
        model = CreateAccountViewModel()
        
        model.bootstrap()
    }
}
