//
//  SettingWithSwitchTableViewCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

class SettingWithSwitchTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var isEnabledSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isEnabledSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    }
    
    func setModel(model: SettingWithSwitchVM) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        isEnabledSwitch.isOn = model.isEnabled

        isEnabledSwitch.reactive.isOn.bind(to: model.switchAction)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
