//
//  SettingWithIconTableViewCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class SettingWithIconTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var settingIcon: UIImageView!
    
    func setModel(model: SettingWithIconVM) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        settingIcon.image = model.icon
        
        self.reactive.tapGesture().throttle(seconds: 0.5).map { _ in }.bind(to: model.action).dispose(in: reactive.bag)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
