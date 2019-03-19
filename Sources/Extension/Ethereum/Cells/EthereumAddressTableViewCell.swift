//
//  EthereumAddressTableViewCell.swift
//  Extension
//
//  Created by Yehor Popovych on 3/19/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK

class EthereumAddressTableViewCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var emojiView: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    
    func setAccount(account: Account, header: String) {
        iconView.isHidden = true
        emojiView.isHidden = false
        headerLabel.text = header
        emojiView.text = account.associatedData[.emoji]?.string
        accountLabel.text = account.associatedData[.name]?.string
    }
    
    func setAddress(address: EthereumAddress, header: String, icon: UIImage) {
        iconView.isHidden = false
        emojiView.isHidden = true
        headerLabel.text = header
        iconView.image = icon
        accountLabel.text = address.hex(eip55: false)
    }
    
    
}
