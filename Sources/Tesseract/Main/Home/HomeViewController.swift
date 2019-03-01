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

class HomeViewController: UIViewController {
  typealias ViewModel = HomeViewModel
  
  private(set) var model: ViewModel!
  
  // MARK: Outlets
  //
  @IBOutlet weak var activityTableView: UITableView!
  @IBOutlet weak var balanceLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let accountProp = self.model.activeAccount
    
    model.transactions.bind(to: activityTableView, cellType: ActivityTableViewCell.self) { (cell, tx) in
      cell.setModel(model: tx, address: accountProp.value!.address)
    }.dispose(in: bag)
    
    model.balance.bind(to: balanceLabel.reactive.text).dispose(in: bag)
    
    activityTableView.delegate = self
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
    model = HomeViewModel(ethWeb3Service: appCtx.ethereumWeb3Service)
    
    appCtx.activeAccount.bind(to: model.activeAccount).dispose(in: model.bag)
    appCtx.ethereumNetwork.bind(to: model.ethereumNetwork).dispose(in: model.bag)
    
    model.bootstrap()
  }
}