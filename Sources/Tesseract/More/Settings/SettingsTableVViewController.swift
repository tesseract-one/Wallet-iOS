//
//  SettingsTableViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class SettingsTableViewController: UITableViewController, ModelVCProtocol {
    typealias ViewModel = SettingsViewModel
    
    var model: ViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "AccountTableViewCell", bundle: nil), forCellReuseIdentifier: "AccountSetting")
        tableView.register(UINib(nibName: "ButtonWithIconTableViewCell", bundle: nil), forCellReuseIdentifier: "ButtonWithIconSetting")
        tableView.register(UINib(nibName: "SettingWithWordTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingWithWord")
        tableView.register(UINib(nibName: "SettingWithIconTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingWithIcon")
        tableView.register(UINib(nibName: "SettingWithSwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingWithSwitch")
        
        model.tableSettings.bind(to: tableView, animated: true, rowAnimation: .top) { data, indexPath, tableView in
            let item = data[itemAt: indexPath]
            switch item {
            case let account as SettingWithAccountVM:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AccountSetting") as! AccountTableViewCell
                cell.model = account
                return cell
            case let buttonWithIcon as ButtonWithIconVM:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonWithIconSetting") as! ButtonWithIconTableViewCell
                cell.model = buttonWithIcon
                return cell
            case let settingWithWord as SettingWithWordVM:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingWithWord") as! SettingWithWordTableViewCell
                cell.model = settingWithWord
                return cell
            case let settingWithIcon as SettingWithIconVM:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingWithIcon") as! SettingWithIconTableViewCell
                cell.model = settingWithIcon
                return cell
            case let settingWithSwitch as SettingWithSwitchVM:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingWithSwitch") as! SettingWithSwitchTableViewCell
                cell.model = settingWithSwitch
                return cell
            default:
                fatalError("Unknown cell type")
            }
        }
        .dispose(in: reactive.bag)
        
        combineLatest(model.accounts, model.activeAccount.filter{ $0 != nil })
            .observeNext { [weak self] accounts, activeAccount in
                let activeAccountIndex = self!.model.accounts.collection.firstIndex(of: activeAccount!).int!
                self?.tableView.selectRow(at: IndexPath(row: activeAccountIndex, section: 0), animated: false, scrollPosition: .none)
            }.dispose(in: reactive.bag)
        
        tableView.reactive.selectedRowIndexPath.throttle(seconds: 0.1)
            .filter { Int($0.section) == 0 }
            .map { Int($0.row) }
            .with(latestFrom: model.accounts)
            .filter { $1.collection.count > $0 } // not last elements in this section (like addAccount)
            .map { accountIndex, accounts in
                accounts.collection[accountIndex]
            }
            .bind(to: model.activeAccount)
            .dispose(in: reactive.bag)
        
        goToViewAction.observeNext { [weak self] name, context in
            let vc = try! self?.viewController(for: .named(name: name), context: context)
            self?.navigationController?.pushViewController(vc!, animated: true)
        }.dispose(in: bag)
    }
}

extension SettingsTableViewController {
    private func getSectionTitle(_ section: Int) -> String {
        switch section {
        case 0:
            return "Your Accounts"
        case 1:
            return "Settings"
        case 2:
            return "Developer Tools"
        case 3:
            return "Other"
        default:
            fatalError("Unknown section number")
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 53))
        header.backgroundColor = UIColor(red: 37/255, green: 37/255, blue: 37/255, alpha: 1.0)
        
        let label: UILabel = UILabel.init(frame: CGRect(x: 16, y: 24, width: tableView.frame.width - 32, height: 21))
        label.text = getSectionTitle(section)
        label.font = UIFont(name: "SFProDisplay-Semibold", size: 14)
        label.sizeToFit()
        label.textColor = UIColor.init(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        
        header.addSubview(label)
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
}

extension SettingsTableViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        model = SettingsViewModel(walletService: appCtx.walletService, changeRateService: appCtx.changeRatesService, settings: appCtx.settings)
        
        appCtx.wallet.bind(to: model.wallet).dispose(in: model.bag)
        appCtx.activeAccount.bidirectionalBind(to: model.activeAccount).dispose(in: model.bag)
        appCtx.ethereumNetwork.bind(to: model.network).dispose(in: model.bag)
        
        model.bootstrap()
    }
}
