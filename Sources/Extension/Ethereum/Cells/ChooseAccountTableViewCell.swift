//
//  ChooseAccountTableViewCell.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/5/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK

class ChooseAccountTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var emoji: UILabel!
    @IBOutlet weak var selectedIcon: UILabel!
    
    var index: UInt32 = 0
    
    func setModel(model: Account) {
        name.text = model.associatedData[.name]?.string ?? "Account"
        emoji.text =  model.associatedData[.emoji]?.string ?? "\u{1F9B9}"
        index = model.index
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        selectedIcon.isHidden = !selected
    }
}
