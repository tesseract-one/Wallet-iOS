//
//  AppsTableViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/5/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

struct AppAsset: NamedAsset {
  var name: String
  var abbreviation: String
  var icon: UIImage?
  var accounts: [Account]
}

class AppsTableViewController: AssetsTemplateTableViewController<AppAsset, AppsTableViewCell> {
  
  override func loadAssets() {
    assets = AppState.shared.wallet?.stub.apps.map({ (app) -> (AppAsset) in
      return AppAsset.init(
        name: app.name,
        abbreviation: app.token.abbreviation,
        icon: app.icon,
        accounts: app.accounts
      )
    }) ?? []
  }
}
