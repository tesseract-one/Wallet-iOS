//
//  NetworkTableViewCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/29/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

public typealias NetworkType = (name: String, abbr: String, type: String, index: UInt64)

public let NETWORKS: [NetworkType] = [
    ("Ethereum Network", "ETH", "Main Network", index: 1),
    ("Ropsten Network", "RPN", "Test Network", index: 2),
    ("Kovan Network", "KVN", "Test Network", index: 42),
    ("Rinkeby Network", "RKB", "Test Network", index: 4)
]

class NetworkTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var isCheckedIcon: UIImageView!
    
    func setModel(model: NetworkType) {
        nameLabel.text = "\(model.name) (\(model.abbr))"
        descriptionLabel.text = model.type
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        isCheckedIcon.isHidden = !selected
    }
    
}
