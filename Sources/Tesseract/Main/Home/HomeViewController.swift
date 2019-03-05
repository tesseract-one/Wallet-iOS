//
//  HomeViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond
import TesSDK

class HomeViewController: UIViewController, ModelVCProtocol {
    typealias ViewModel = HomeViewModel
    
    private(set) var model: ViewModel!
    
    // MARK: Outlets
    //
    @IBOutlet weak var activityTableView: UITableView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var receiveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let accountProp = self.model.activeAccount
        
        model.transactions.bind(to: activityTableView, cellType: TransactionTableViewCell.self) { (cell, tx) in
            cell.setModel(model: tx, address: accountProp.value!.address)
            print("Color", cell.backgroundView, cell.backgroundView?.backgroundColor)
        }.dispose(in: bag)
        
        model.balance.bind(to: balanceLabel.reactive.text).dispose(in: bag)
        
        sendButton.reactive.tap.throttle(seconds: 0.5)
            .bind(to: model.sendAction).dispose(in: bag)
        receiveButton.reactive.tap.throttle(seconds: 0.5)
            .bind(to: model.receiveAction).dispose(in: bag)
        
        model.goToSendView.observeNext { [weak self] name, context in
            let vc = try? UIStoryboard(name: "Send", bundle: nil)
                .viewFactory(context: self?.r_context)
                .viewController(for: .root, context: context)
            self?.show(vc!, sender: self!)
        }.dispose(in: bag)
        
        model.goToReceiveView.observeNext { [weak self] name, context in
            let vc = try? UIStoryboard(name: "Receive", bundle: nil)
                .viewFactory(context: self?.r_context)
                .viewController(for: .root, context: context)
            self?.show(vc!, sender: self!)
        }.dispose(in: bag)
        
        model.closePopupView.with(weak: self).observeNext { sself in
            if sself.presentedViewController != nil {
                sself.dismiss(animated: true, completion: nil)
            }
        }.dispose(in: bag)
        
        activityTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.updateBalance()
    }
    // MARK: Default values
    // Make the Status Bar Light/Dark Content for this View
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 16))
        header.backgroundColor = UIColor.init(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        
        let label: UILabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 16))
        label.text = "Latest Activity"
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.init(red: 0.57, green: 0.57, blue: 0.57, alpha: 1.0)
        
        header.addSubview(label)
        
        return header
    }
}

extension HomeViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        model = HomeViewModel(
            ethWeb3Service: appCtx.ethereumWeb3Service,
            changeRateService: appCtx.changeRatesService
        )
        
        appCtx.activeAccount.bind(to: model.activeAccount).dispose(in: model.bag)
        appCtx.ethereumNetwork.bind(to: model.ethereumNetwork).dispose(in: model.bag)
        
        model.bootstrap()
    }
}
