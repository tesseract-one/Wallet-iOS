//
//  EthereumKeychainAccountsViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK
import ReactiveKit
import MaterialTextField
import Bond

class EthereumKeychainAccountsViewController: EthereumKeychainViewController<OpenWalletEthereumAccountKeychainRequest>,
    EthereumKeychainViewControllerBaseControls {
   
    let accounts = MutableObservableArray<Account>()
    let activeAccountIndex = Property<Int>(-1)
    
    private var topConstraintInitial: CGFloat = 0.0

    @IBOutlet weak var chooseAccountTableView: UITableView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var passwordField: MFTextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Access Request"
        
        context.wallet
            .map{$0.exists?.accounts ?? []}
            .bind(to: accounts)
            .dispose(in: reactive.bag)
        
        accounts.bind(to: chooseAccountTableView, cellType: ChooseAccountTableViewCell.self) { cell, account in
            cell.setModel(model: account)
            return
        }.dispose(in: bag)
        
        context.activeAccount.map{ $0 != nil ? Int($0!.index) : -1}.bind(to: activeAccountIndex).dispose(in: reactive.bag)
        
        combineLatest(accounts, activeAccountIndex.filter{$0 >= 0}).observeNext { [weak self] accounts, index in
            if (accounts.collection.count > index) {
                self?.chooseAccountTableView.selectRow(at: IndexPath(row: Int(index), section: 0), animated: true, scrollPosition: .middle)
            }
        }.dispose(in: reactive.bag)
        
        chooseAccountTableView.reactive.selectedRowIndexPath.throttle(seconds: 0.5).map{Int($0.item)}.bind(to: activeAccountIndex)
        
        runWalletOperation
            .with(latestFrom: context.wallet)
            .with(latestFrom: activeAccountIndex)
            .map { (arg, accountIndex) -> String in
                let (_, wallet) = arg
                let account = wallet.exists?.accounts.first { $0.index == accountIndex }
                return try! account!.eth_address().hex(eip55: false)
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
