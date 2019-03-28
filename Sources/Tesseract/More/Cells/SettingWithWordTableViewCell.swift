//
//  SettingWithWordTableViewCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class SettingWithWordTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var settingLabel: UILabel!
    
    func setModel(model: SettingWithWordVM) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        settingLabel.textColor = model.isEnabled ? .white : UIColor(red: 92/255, green: 92/255, blue: 92/255, alpha: 1.0)
        
        model.word.bind(to: settingLabel.reactive.text).dispose(in: reactive.bag)
        if model.isEnabled {
            self.reactive.tapGesture().throttle(seconds: 0.5).map { _ in }
                .bind(to: model.action!).dispose(in: reactive.bag)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
