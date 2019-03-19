//
//  EthereumDataTypeTableViewCell.swift
//  Extension
//
//  Created by Yehor Popovych on 3/19/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class EthereumDataTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    func setData(type: String, field: String) {
        dataLabel.text = "\(field): \(type)"
    }
    
    func setIndent(level: Int) {
        leadingConstraint.constant = level > 0 ? CGFloat(level) * 8 : 0
    }
}
