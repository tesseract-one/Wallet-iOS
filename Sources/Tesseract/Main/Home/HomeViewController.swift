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

class HomeViewController: UITableViewController, ModelVCProtocol {
    typealias ViewModel = HomeViewModel
    
    private(set) var model: ViewModel!
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var receiveButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let accountProp = self.model.activeAccount
        
        model.transactions.bind(to: self.tableView, cellType: TransactionTableViewCell.self) { cell, tx in
            cell.setModel(model: tx, address: try! accountProp.value!.eth_address().hex(eip55: false))
            return
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
                sself.model.updateBalance()
            }
        }.dispose(in: bag)
        
        // 190 = height without card, (self.view.frame.width - 32) * 184/343 = width of card * proportion of card
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 190 + (self.view.frame.width - 32) * 184/343)
    }
}

extension HomeViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 16))
        header.backgroundColor = UIColor.init(red: 37/255, green: 37/255, blue: 37/255, alpha: 1.0)
        
        let label: UILabel = UILabel.init(frame: CGRect(x: 16, y: 0, width: tableView.frame.width - 32, height: 16))
        label.text = "Latest Activity"
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.init(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        
        header.addSubview(label)
        
        return header
    }
}

extension HomeViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        model = HomeViewModel(
            ethWeb3Service: appCtx.ethereumWeb3Service,
            changeRateService: appCtx.changeRatesService,
            transactionInfoService: appCtx.transactionService
        )
        
        appCtx.activeAccount.bind(to: model.activeAccount).dispose(in: model.bag)
        appCtx.ethereumNetwork.bind(to: model.ethereumNetwork).dispose(in: model.bag)
        appCtx.balance.bind(to: model.ethBalance).dispose(in: model.bag)
        appCtx.transactions.observeNext { [weak model] txs in
            model?.transactions.replace(with: txs ?? [])
        }.dispose(in: model.bag)
        
        model.bootstrap()
    }
}
