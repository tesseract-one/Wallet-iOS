//
//  EthereumAddressTableViewCell.swift
//  Extension
//
//  Created by Yehor Popovych on 3/19/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import Wallet

class EthereumAddressTableViewCell: UITableViewCell {

    @IBOutlet weak var emojiView: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    
    func setAccount(account: Account, header: String) {
        headerLabel.text = header
        emojiView.text = account.associatedData[.emoji]?.string
        accountLabel.text = account.associatedData[.name]?.string
    }
}
