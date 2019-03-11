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
import Material
import Bond

class EthereumKeychainAccountsViewController: EthereumKeychainViewController<OpenWalletEthereumAccountKeychainRequest>,
    EthereumKeychainViewControllerBaseControls {
   
    let accounts = MutableObservableArray<Account>()
    let activeAccountIndex = Property<UInt32>(0)

    @IBOutlet weak var chooseAccountTableView: UITableView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var passwordField: ErrorTextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blurredView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Access Request"
        
        context.wallet
            .map{$0?.accounts ?? []}
            .bind(to: accounts)
            .dispose(in: reactive.bag)
        
        accounts.bind(to: chooseAccountTableView, cellType: ChooseAccountTableViewCell.self) { cell, account in
            cell.setModel(model: account)
            return
        }.dispose(in: bag)
        
        context.activeAccount.map{$0?.index ?? 0}.bind(to: activeAccountIndex).dispose(in: reactive.bag)
        
//        activeAccountIndex.with(weak: self).observeNext { index, sself in
//            sself.chooseAccountTableView.selectRow(at: IndexPath(row: Int(index), section: 0), animated: true, scrollPosition: .middle)
//        }.dispose(in: reactive.bag)
        
        chooseAccountTableView.reactive.selectedRowIndexPath.throttle(seconds: 0.5).map{UInt32($0.item)}.bind(to: activeAccountIndex)
        
        runWalletOperation
            .with(latestFrom: context.wallet)
            .with(latestFrom: activeAccountIndex)
            .map { (arg, accountIndex) -> String in
                let (_, wallet) = arg
                let account = wallet?.accounts.first { $0.index == accountIndex }
                return try! account!.eth_address()
            }
            .with(weak: self)
            .observeNext { address, sself in
                sself.succeed(response: address)
            }.dispose(in: reactive.bag)
        
        blurView()
    }
    
    private func blurView() {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurredView.layout(visualEffectView).edges()
        blurredView.sendSubviewToBack(visualEffectView)
    }
}
