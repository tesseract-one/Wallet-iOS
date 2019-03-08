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
        let nameTitle = model.associatedData[.name]
        let emojiTitle = model.associatedData[.emoji]
        name.text = nameTitle != nil ? String(nameTitle!) : "Account"
        emoji.text = emojiTitle != nil ? String(emojiTitle!) : "🦹‍"
        index = model.index
//        selectedIcon.isHidden = model.index == activeAccountIndex
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        selectedIcon.isHidden = !selected
    }
}
