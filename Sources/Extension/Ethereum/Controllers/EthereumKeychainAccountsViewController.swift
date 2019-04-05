//
//  EthereumKeychainAccountsViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import MaterialTextField
import Bond
import Wallet
import OpenWallet

class EthereumKeychainAccountsViewController: EthereumKeychainViewController<EthereumAccountKeychainRequest>,
    EthereumKeychainViewControllerBaseControls {
   
    let activeAccount = Property<AccountViewModel?>(nil)
    let accounts = MutableObservableArray<AccountViewModel>()
    
    private var topConstraintInitial: CGFloat = 0.0

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var fingerButton: UIButton!
    @IBOutlet weak var passwordField: MFTextField!
    
    @IBOutlet weak var acceptBtnRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var chooseAccountTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Access Request"
        
        context.wallet.filter { $0 != nil }.flatMapLatest { $0!.accounts }
            .bind(to: accounts).dispose(in: reactive.bag)
        
        accounts.bind(to: chooseAccountTableView, cellType: ChooseAccountTableViewCell.self) { cell, account in
            cell.model = account
        }.dispose(in: bag)
        
        context.activeAccount.bind(to: activeAccount).dispose(in: reactive.bag)
        
        combineLatest(accounts.filter{$0.collection.count > 0}, activeAccount.filter{$0 != nil})
            .observeNext { [weak self] accounts, activeAccount in
                let activeAccountIndex = accounts.collection.firstIndex(of: activeAccount!).int!
                self?.chooseAccountTableView.selectRow(at: IndexPath(row: activeAccountIndex, section: 0), animated: true, scrollPosition: .middle)
            }.dispose(in: reactive.bag)
        
        chooseAccountTableView.reactive.selectedRowIndexPath.throttle(seconds: 0.1)
            .map { Int($0.row) }
            .with(latestFrom: accounts)
            .map { accountIndex, accounts in
                accounts.collection[accountIndex]
            }
            .bind(to: activeAccount)
            .dispose(in: reactive.bag)
        
        runWalletOperation
            .with(latestFrom: activeAccount)
            .map { _, activeAccount -> String in
                return try! activeAccount!.eth_address().hex(eip55: false)
            }
            .with(weak: self)
            .observeNext { address, sself in
                sself.succeed(response: address)
            }.dispose(in: reactive.bag)
        
         self.topConstraintInitial = self.topConstraint.constant
    }
    
    override func moveConstraints(keyboardHeight: CGFloat?) {
        super.moveConstraints(keyboardHeight: keyboardHeight)
        
        if let height = keyboardHeight {
            self.topConstraint.constant = self.topConstraintInitial - height
        } else {
            self.topConstraint.constant = self.topConstraintInitial
        }
    }
}
