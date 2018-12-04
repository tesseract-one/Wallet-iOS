//
//  TokensTableViewCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/30/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class TokensTableViewCell: UITableViewCell {

  //MARK: Properties
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var balanceUSDLabel: UILabel!
  @IBOutlet weak var balanceUpdateLabel: UILabel!
  @IBOutlet weak var tokenImageView: UIImageView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
  
  var token: Token?
  var wasSelected: Bool = false
  var currentHeight: CGFloat = 60
  var extendedHeight: CGFloat = 60
  var appCellHeight: Double = 36
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    if !selected {
      removeApps()
      wasSelected = false
      currentHeight = 60
    } else if !wasSelected {
      addApps()
      currentHeight = extendedHeight
      wasSelected = true
    }
  }
  
  // MARK: Public functions
  //
  func setUp(_ token: Token) {
    self.token = token
    
    nameLabel.text = token.name
    balanceLabel.text = "\(String(token.balance)) \(token.abbreviation)"
    balanceUSDLabel.text = "$\(String(Double(token.balance * token.price).rounded(toPlaces: 2)))"
    tokenImageView.image = token.icon
    
    let tokenBalanceUpdateText = "\(String(Double(token.balanceUpdate ?? 0).rounded(toPlaces: 2))) \(token.abbreviation)"
    
    if token.balanceUpdate == nil || token.balanceUpdate! <= 0.0 {
      balanceUpdateLabel.text = tokenBalanceUpdateText
    } else {
      balanceUpdateLabel.text = "+\(tokenBalanceUpdateText)"
    }
  }
  
  // MARK: Private functions
  //
  private func addApps() {
    guard let token = self.token else {
      fatalError("Token is missed in TokensTableViewCell")
    }
    
    let apps = token.apps
    
    guard apps.count > 0 else {
      return
    }
    
    stackViewHeight.constant = CGFloat(apps.count >= 4 ? appCellHeight * 4 : appCellHeight * Double(apps.count))
    stackView.updateConstraints()
    
    extendedHeight = stackViewHeight.constant + 60
    
    let shownApps = apps.prefix(3)
    
    for app in shownApps {
      addAppView(app.name, app.balance, token.abbreviation)
    }
    
    if apps.count > 3 {
      let hiddenApps = apps[3...]
      let hiddenAppsBalance = hiddenApps.reduce(0, { (acc, hiddenApp) -> Double in
        acc + hiddenApp.balance
      })
      
      addAppView("…and \(hiddenApps.count) more Apps", hiddenAppsBalance, token.abbreviation)
    }
  }
  
  private func removeApps() {
    stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
  }
  
  private func addAppView(_ appName: String, _ appBalance: Double, _ tokenAbbreviation: String) {
    let appView = UINib(nibName: "TokensTableViewExpandedCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! TokensTableViewExpandedCell
    
    appView.appLabel.text = appName
    appView.balanceLabel.text = "\(String(Double(appBalance).rounded(toPlaces: 2))) \(tokenAbbreviation)"
    
    stackView.addArrangedSubview(appView)
  }
}
