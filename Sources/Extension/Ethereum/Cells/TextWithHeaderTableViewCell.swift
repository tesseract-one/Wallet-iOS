//
//  TextWithHeaderTableViewCell.swift
//  Extension
//
//  Created by Yehor Popovych on 3/19/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class TextWithHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerlabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!

    func setData(header: String?, data: String?) {
        headerlabel.text = header
        dataLabel.text = data
    }
    
    func setIndent(level: Int) {
        leadingConstraint.constant = level > 0 ? CGFloat(level) * 16 : 0
    }
}
