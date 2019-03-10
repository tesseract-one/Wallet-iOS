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

class EthereumKeychainAccountsViewController: EthereumKeychainViewController<OpenWalletEthereumAccountKeychainRequest>, UITableViewDelegate, EthereumKeychainViewControllerBaseControls {
   
    let accounts = MutableObservableArray<Account>()
    let activeAccountIndex = Property<UInt32>(0)

    @IBOutlet weak var chooseAccountTableView: UITableView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var passwordField: ErrorTextField!
    
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
        
        chooseAccountTableView.delegate = self
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
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 16))
        header.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.0)
        
        let label: UILabel = UILabel.init(frame: CGRect(x: 16, y: 0, width: tableView.frame.width - 32, height: 16))
        label.text = "Accounts"
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.init(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        
        header.addSubview(label)
        
        return header
    }
}
