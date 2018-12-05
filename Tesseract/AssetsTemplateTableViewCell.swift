//
//  AssetsTemplateTableViewCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/5/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class AssetsTemplateTableViewCell<A>: UITableViewCell {

  //MARK: Properties
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
  
  var asset: A?
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
      removeAssets()
      wasSelected = false
      currentHeight = 60
    } else if !wasSelected {
      addAssets()
      currentHeight = extendedHeight
      wasSelected = true
    }
  }
  
  // MARK: Public functions
  //
  public func removeAssets() {
    stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
  }
  
  public func addAssetSubView(_ assetName: String, _ assetBalance: Double, _ tokenAbbreviation: String) {
    let assetSubView = UINib(nibName: "AssetsTableViewExpandedCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! AssetsTableViewExpandedCell
    
    assetSubView.assetLabel.text = assetName
    assetSubView.balanceLabel.text = "\(String(Double(assetBalance).rounded(toPlaces: 2))) \(tokenAbbreviation)"
    
    stackView.addArrangedSubview(assetSubView)
  }
  
  // MARK: Internal functions
  //
  internal func setUp(_ asset: A) {}
  internal func addAssets() {}
}
