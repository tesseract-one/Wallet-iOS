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
    @IBOutlet weak var leftLineTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var borderedView: BorderedView!
    
    func setData(type: String, field: String) {
        dataLabel.text = "\(field): \(type)"
    }
    
    func setIndent(level: Int) {
        leadingConstraint.constant = level > 0 ? CGFloat(level) * 16 : 0
        leftLineTopConstraint.constant = bounds.height / 2.0
    }
}
