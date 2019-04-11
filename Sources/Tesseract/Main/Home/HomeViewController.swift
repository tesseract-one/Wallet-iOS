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
    
    @IBOutlet weak var accountEmojiLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var balanceETHLabel: UILabel!
    @IBOutlet weak var balanceUSDLabel: UILabel!
    @IBOutlet weak var balanceUpdateLabel: UILabel!
    @IBOutlet weak var balanceUpdateAsPercentLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var receiveButton: UIButton!
    
    @IBOutlet weak var balanceUpdateLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var balanceUpdateAsPercentLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var cardView: UIImageView!
    @IBOutlet weak var accountView: UIStackView!
    @IBOutlet weak var cardTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        model.transactions.bind(to: self.tableView, cellType: TransactionTableViewCell.self) { [weak self] cell, tx in
            let address = try! self!.model.activeAccount.value!.eth_address().hex(eip55: false)
            let rate = self!.model.changeRateService.changeRates[.Ethereum]
            cell.setValues(address: address, rate: rate!)
            cell.model = tx
        }.dispose(in: bag)
        
        model.balanceUSD.bind(to: balanceUSDLabel.reactive.text).dispose(in: reactive.bag)
        model.balanceETH.bind(to: balanceETHLabel.reactive.text).dispose(in: reactive.bag)
        
        model.balanceUpdateUSD.bind(to: balanceUpdateLabel.reactive.text).dispose(in: reactive.bag)
        model.balanceUpdateInPercent.bind(to: balanceUpdateAsPercentLabel.reactive.text).dispose(in: reactive.bag)
        
        let activeAccount = model.activeAccount.filter { $0 != nil }
        activeAccount
            .flatMapLatest { $0!.emoji }
            .bind(to: accountEmojiLabel.reactive.text)
            .dispose(in: reactive.bag)
        activeAccount
            .flatMapLatest { $0!.name }
            .bind(to: accountNameLabel.reactive.text)
            .dispose(in: reactive.bag)
        
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
        
        setupAccountView()
        setupSizes()
    }
}

extension HomeViewController {
    private func setupSizes() {
        if UIScreen.main.bounds.width > 320 {
            balanceUpdateLeftConstraint.constant = 32
            balanceUpdateAsPercentLeftConstraint.constant = 32
            separatorView.isHidden = false
        } else {
            balanceUpdateLeftConstraint.constant = 16
            balanceUpdateAsPercentLeftConstraint.constant = 16
            separatorView.isHidden = true
        }
    }
    
    private func setupAccountView() {
        model.isMoreThanOneAccount.with(weak: self)
            .observeNext { isMoreThanOneAccount, sself in
                if isMoreThanOneAccount {
                    sself.cardTopConstraint.constant = 76
                    sself.accountView.isHidden = false
                    let newHeight: CGFloat = 182.0 + (sself.view.frame.width - 32.0) * 202.0/343.0
                    sself.tableView.tableHeaderView!.frame.size.height = newHeight
                } else {
                    sself.cardTopConstraint.constant = 24
                    sself.accountView.isHidden = true
                    let newHeight: CGFloat = 130.0 + (sself.view.frame.width - 32.0) * 202.0/343.0
                    sself.tableView.tableHeaderView!.frame.size.height = newHeight
                }
                
                sself.tableView.reloadData()
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
        appCtx.balance.bind(to: model.balance).dispose(in: model.bag)
        appCtx.transactions.observeNext { [weak model] txs in
            model?.transactions.replace(with: txs ?? [])
        }.dispose(in: model.bag)
        
        model.bootstrap()
    }
}
