//
//  LogoutTableViewCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class LogoutTableViewCell: ViewModelCell<LogoutVM> {
    @IBOutlet weak var title: UILabel!
    
    override func advise() {
        guard let model = self.model else { return }
        
        title.text = model.title
        
        self.reactive.tapGesture().throttle(seconds: 0.1).map { _ in }
            .bind(to: model.action).dispose(in: bag)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
