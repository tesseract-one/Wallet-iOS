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
        
        model.network
            .with(weak: self)
            .delay(interval: 0.01, on: .main) // should be after table creates
            .observeNext { networkIndex, sself in
                let index = sself.model.networks.collection.firstIndex { $0.index == networkIndex }
                if let index = index {
                    sself.tableView.selectRow(
                        at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .middle
                    )
                }
                
            }.dispose(in: reactive.bag)
        
        tableView.reactive.selectedRowIndexPath
            .distinctUntilChanged()
            .throttle(seconds: 0.1)
            .with(weak: self)
            .map { path, sself in sself.model.networks.collection[path.item].index }
            .bind(to: model.changeNetworkAction)
            .dispose(in: reactive.bag)
        
        backButton.reactive.tap.throttle(seconds: 0.5)
            .observeNext { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }.dispose(in: reactive.bag)
        
        tableView.tableFooterView = UIView() // remove separators below last cell
    }
}

extension ChooseNetworkTableViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        header.backgroundColor = UIColor(red: 37/255, green: 37/255, blue: 37/255, alpha: 1.0)
        
        let label: UILabel = UILabel.init(frame: CGRect(x: 16, y: 35, width: tableView.frame.width - 32, height: 0))
        label.text = "Available Networks"
        label.font = UIFont(name: "SFProDisplay-Semibold", size: 14)
        label.sizeToFit()
        label.textColor = UIColor.init(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        label.sizeToFit()
        label.layoutIfNeeded()
        
        header.addSubview(label)
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: header.frame.height - 0.5, width: header.frame.width, height: 0.5)
        bottomBorder.backgroundColor = UIColor(red: 21/255, green: 21/255, blue: 21/255, alpha: 0.5).cgColor
        header.layer.addSublayer(bottomBorder)
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 54))
        footer.backgroundColor = UIColor(red: 37/255, green: 37/255, blue: 37/255, alpha: 1.0)
        
        let label: UILabel = UILabel.init(frame: CGRect(x: 16, y: 9, width: tableView.frame.width - 32, height: 0))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.25
        let attrString = NSAttributedString(
            string: "Every dApp will use the network it demands. So you don't need to change it by yourself.",
            attributes: [
                .font: UIFont(name: "SFProDisplay-Regular", size: 12)!,
                .foregroundColor: UIColor.init(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0),
                .paragraphStyle: paragraphStyle
            ]
        )
        
        label.attributedText = attrString
        label.numberOfLines = 0
        label.sizeToFit()
        label.layoutIfNeeded()
        
        footer.addSubview(label)
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: footer.frame.width, height: 0.5)
        topBorder.backgroundColor = UIColor(red: 21/255, green: 21/255, blue: 21/255, alpha: 0.5).cgColor
        footer.layer.addSublayer(topBorder)
        
        return footer
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
