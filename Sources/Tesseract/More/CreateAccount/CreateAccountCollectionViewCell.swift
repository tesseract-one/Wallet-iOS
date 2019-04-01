//
//  CreateAccountCollectionViewCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class CreateAccountCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var emojiLabel: UILabel!
    
    func setupCell(emoji: String) {
        emojiLabel.text = emoji
    }
}
