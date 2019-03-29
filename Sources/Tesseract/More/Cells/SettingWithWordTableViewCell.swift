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
        settingLabel.textColor = model.isEnabled ? .white : UIColor(red: 92/255, green: 92/255, blue: 92/255, alpha: 1.0)
        
        if let description = model.description {
            descriptionLabel.text = description
        } else {
            model.activeDescription!.bind(to: descriptionLabel.reactive.text).dispose(in: reactive.bag)
        }

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
