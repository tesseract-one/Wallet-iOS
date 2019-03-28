//
//  ButtonWithIconTableViewCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class ButtonWithIconTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    func setModel(model: ButtonWithIconVM) {
        title.text = model.title
        icon.image = model.icon
        
        self.reactive.tapGesture().throttle(seconds: 0.5).map { _ in }
            .bind(to: model.action).dispose(in: reactive.bag)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
