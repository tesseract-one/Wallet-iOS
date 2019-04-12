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
    @IBOutlet weak var editButton: UIButton!
    
    override func advise() {
        guard let model = self.model else { return }
        
        model.name.bind(to: nameLabel.reactive.text).dispose(in: bag)
        model.emoji.bind(to: emojiLabel.reactive.text).dispose(in: bag)
        model.balance.bind(to: balanceLabel.reactive.text).dispose(in: bag)
        editButton.reactive.tap.throttle(seconds: 0.1).with(weak: model).map { $0.accountId }
            .bind(to: model.editAction).dispose(in: bag)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        selectedIcon.isHidden = !selected
    }
}
