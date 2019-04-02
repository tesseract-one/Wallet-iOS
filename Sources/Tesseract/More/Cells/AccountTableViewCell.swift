//
//  AccountTableViewCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class AccountTableViewCell: ViewModelCell<SettingWithAccountVM> {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var selectedIcon: UIImageView!
    
    var index: UInt32 = 0
    
    override func advise() {
        guard let model = self.model else { return }
        
        nameLabel.text = model.name
        emojiLabel.text = model.emoji
        index = model.index
        
        model.balance.bind(to: balanceLabel.reactive.text).dispose(in: bag)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        selectedIcon.isHidden = !selected
    }
}