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

class SettingWithSwitchTableViewCell: ViewModelCell<SettingWithSwitchVM> {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var isEnabledSwitch: UISwitch!
    
    let toggleSwithAction = PassthroughSubject<Bool, Never>()
    
    override func advise() {
        guard let model = self.model else { return }
        
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        isEnabledSwitch.setOn(model.isEnabled, animated: false)

        self.reactive.tapGesture().throttle(seconds: 0.1)
            .map{ _ in }
            .with(weak: isEnabledSwitch)
            .map { !$0.isOn }
            .bind(to: toggleSwithAction)
            .dispose(in: bag)
        
        toggleSwithAction.bind(to: isEnabledSwitch.reactive.isOn).dispose(in: bag)
        // when we change isEnabledSwitch.reactive.isOn from code, we can't subscribe on this change
        toggleSwithAction.merge(with: isEnabledSwitch.reactive.isOn).bind(to: model.switchAction).dispose(in: bag)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
