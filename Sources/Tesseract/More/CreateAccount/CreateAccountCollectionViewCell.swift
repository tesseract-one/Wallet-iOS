//
//  CreateAccountCollectionViewCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class CreateAccountCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var emojiLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(emoji: String) {
        emojiLabel.text = emoji
        emojiLabel.isUserInteractionEnabled = false
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.shadowColor = UIColor(red: 74/255, green: 148/255, blue: 227/255, alpha: 1.0).cgColor
                layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            } else {
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
            }
        }
    }
}
