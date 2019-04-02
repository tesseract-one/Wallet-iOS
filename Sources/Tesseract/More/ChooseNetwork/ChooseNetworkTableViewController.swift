//
//  ChooseNetworkTableViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/29/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class ChooseNetworkTableViewController: UITableViewController, ModelVCProtocol {
    typealias ViewModel = ChooseNetworkViewModel
    
    var model: ViewModel!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.networks.bind(to: tableView, cellType: NetworkTableViewCell.self) { cell, network in
            cell.setModel(model: network)
        }.dispose(in: reactive.bag)
        
        model.network.map{ Int($0) - 1 }
            .with(weak: tableView)
            .delay(interval: 0.01, on: .main) // should be after table creates
            .observeNext { networkIndex, tableView in
                tableView.selectRow(at: IndexPath(row: networkIndex, section: 0), animated: true, scrollPosition: .middle)
            }.dispose(in: reactive.bag)
        
        tableView.reactive.selectedRowIndexPath.distinctUntilChanged().throttle(seconds: 0.1).map{ UInt64($0.item) + 1 }
            .bind(to: model.changeNetworkAction).dispose(in: reactive.bag)
        
        backButton.reactive.tap.throttle(seconds: 0.5)
            .observeNext { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }.dispose(in: reactive.bag)
    }
}

extension ChooseNetworkTableViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 53))
        header.backgroundColor = UIColor(red: 37/255, green: 37/255, blue: 37/255, alpha: 1.0)
        
        let label: UILabel = UILabel.init(frame: CGRect(x: 16, y: 27, width: tableView.frame.width - 32, height: 21))
        label.text = "Available Networks"
        label.font = UIFont(name: "SFProDisplay-Semibold", size: 14)
        label.sizeToFit()
        label.textColor = UIColor.init(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        
        header.addSubview(label)
        
        return header
    }
}

extension ChooseNetworkTableViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        model = ChooseNetworkViewModel(settings: appCtx.settings)
        
        appCtx.ethereumNetwork.bidirectionalBind(to: model.network).dispose(in: model.bag)
        
        model.bootstrap()
    }
}
