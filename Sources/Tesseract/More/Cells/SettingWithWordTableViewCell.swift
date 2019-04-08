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

class SettingWithWordTableViewCell: ViewModelCell<SettingWithWordVM> {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var chevronIcon: UIImageView!
    
    override func advise() {
        guard let model = self.model else { return }
        
        titleLabel.text = model.title
        chevronIcon.isHidden = !model.isEnabled
        
        if let description = model.description {
            descriptionLabel.text = description
        } else {
            descriptionLabel.isHidden = true
        }
        
        model.word.bind(to: settingLabel.reactive.text).dispose(in: bag)
        
        if model.isEnabled {
            self.reactive.tapGesture().throttle(seconds: 0.1).map { _ in }
                .bind(to: model.action!).dispose(in: bag)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
