//
//  RecieveCoinsTableViewCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/22/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class RecieveCoinsTableViewCell: UITableViewCell {

  //MARK: Properties
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var isSelectedLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    isSelectedLabel.isHidden = !selected
  }
}
