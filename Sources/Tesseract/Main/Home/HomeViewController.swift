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

class HomeViewController: UITableViewController, ModelVCProtocol {
    typealias ViewModel = HomeViewModel
    
    private(set) var model: ViewModel!
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var cardView: UIImageView!
    @IBOutlet weak var accountView: UIStackView!
    @IBOutlet weak var cardTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let accountProp = self.model.activeAccount
        
        model.transactions.bind(to: self.tableView, cellType: TransactionTableViewCell.self) { cell, tx in
            cell.setModel(model: tx, address: try! accountProp.value!.eth_address().hex(eip55: false))
            return
        }.dispose(in: bag)
        
        model.balance.bind(to: balanceLabel.reactive.text).dispose(in: bag)
        
        setupAccountView()
    }
}

extension HomeViewController {
    private func setupAccountView() {
        model.isMoreThanOneAccount.with(weak: self)
            .observeNext { isMoreThanOneAccount, sself in
                if isMoreThanOneAccount {
                    sself.cardTopConstraint.constant = 76
                    sself.accountView.isHidden = false
                    let newHeight: CGFloat = 100.0 + (sself.view.frame.width - 32.0) * 184.0/343.0
                    sself.tableView.tableHeaderView!.frame.size.height = newHeight
                } else {
                    sself.cardTopConstraint.constant = 24
                    sself.accountView.isHidden = true
                    let newHeight: CGFloat = 48.0 + (sself.view.frame.width - 32.0) * 184.0/343.0
                    sself.tableView.tableHeaderView!.frame.size.height = newHeight
                }
            }
            .dispose(in: reactive.bag)
    }
}

extension HomeViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 26))
        header.backgroundColor = .clear

        let label = UILabel(frame: CGRect(x: 16, y: 3, width: tableView.frame.width - 32, height: 26))
        label.text = "Latest Activity"
        label.font = UIFont(name: "SFProDisplay-Medium", size: 12)
        label.sizeToFit()
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
        
        appCtx.wallet.bind(to: model.wallet).dispose(in: model.bag)
        appCtx.activeAccount.bind(to: model.activeAccount).dispose(in: model.bag)
        appCtx.ethereumNetwork.bind(to: model.ethereumNetwork).dispose(in: model.bag)
        appCtx.balance.bind(to: model.ethBalance).dispose(in: model.bag)
        appCtx.transactions.observeNext { [weak model] txs in
            model?.transactions.replace(with: txs ?? [])
        }.dispose(in: model.bag)
        
        model.bootstrap()
    }
}
