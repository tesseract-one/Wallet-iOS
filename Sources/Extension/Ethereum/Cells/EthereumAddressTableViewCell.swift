//
//  EthereumAddressTableViewCell.swift
//  Extension
//
//  Created by Yehor Popovych on 3/19/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class EthereumAddressTableViewCell: ViewModelCell<AccountViewModel> {

    @IBOutlet weak var emojiView: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    
    override func advise() {
        guard let model = self.model else { return }
        
        model.name.bind(to: accountLabel.reactive.text).dispose(in: bag)
        model.emoji.bind(to: emojiView.reactive.text).dispose(in: bag)
    }
    
    func setHeader(header: String) {
        headerLabel.text = header
    }
}
