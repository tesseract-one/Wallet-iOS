//
//  WalletTypeViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/27/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import Bond

class WalletTypeViewController: UIViewController, ModelVCProtocol {
    typealias ViewModel = WalletTypeViewModel
    
    private(set) var model: ViewModel!
    
    @IBOutlet weak var tesseractSeedView: UIView!
    @IBOutlet weak var metamaskSeedView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tesseractSeedView.reactive.tapGesture().throttle(seconds: 0.5)
            .map { _ in SeedType.Tesseract }
            .bind(to: model.chooseSeedAction)
            .dispose(in: bag)
        
        metamaskSeedView.reactive.tapGesture().throttle(seconds: 0.5)
            .map { _ in SeedType.Metamask }
            .bind(to: model.chooseSeedAction)
            .dispose(in: bag)
        
        goToViewAction.observeNext { [weak self] name, context in
            let vc = try! self?.viewController(for: .named(name: name), context: context)
            self?.navigationController?.pushViewController(vc!, animated: true)
        }.dispose(in: bag)
    }
}
    
extension WalletTypeViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        model = WalletTypeViewModel()
    }
}
