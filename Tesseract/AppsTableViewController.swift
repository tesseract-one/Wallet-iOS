//
//  AppsTableViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/5/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class AppsTableViewController: AssetsTemplateTableViewController<App, AppsTableViewCell> {
  
  override func loadAssets() {
    let icon = UIImage(named: "logo")
    let accounts = [
      ("Main", 120.04),
      ("Bonus", 40.24),
      ("Additional", 20.35),
      ("Booze & Strippers", 12.424)
    ]
    
    let app1 = App("Cool Cousin", "CUZ", icon, accounts)!
    let app2 = App("Colu", "CLN", icon, [accounts[1], accounts[2]])!
    let app3 = App("Storj", "STORJ", icon, [accounts[0]])!
    let app4 = App("Deos Games", "DEOS", icon, [accounts[3]])!
    let app5 = App("EOS Knights", "EOS", icon, [accounts[2]])!
    let app6 = App("DopeRaider", "DOPE", icon, [accounts[2], accounts[3]])!
    
    assets += [app1, app2, app3, app4, app5, app6]
  }
}
