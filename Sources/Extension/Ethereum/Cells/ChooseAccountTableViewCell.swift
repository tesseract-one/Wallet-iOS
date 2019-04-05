//
//  ChooseAccountTableViewCell.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/5/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class ChooseAccountTableViewCell: ViewModelCell<AccountViewModel> {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var emoji: UILabel!
    @IBOutlet weak var selectedIcon: UILabel!
    
    override func advise() {
        guard let model = self.model else { return }
        
        model.name.bind(to: name.reactive.text).dispose(in: bag)
        model.emoji.bind(to: emoji.reactive.text).dispose(in: bag)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        selectedIcon.isHidden = !selected
    }
}
