//
//  AddressesTableViewCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/26/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class AddressesTableViewCell: UITableViewCell {
  
  //MARK: Properties
  @IBOutlet weak var addressLabel: UILabel!
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
