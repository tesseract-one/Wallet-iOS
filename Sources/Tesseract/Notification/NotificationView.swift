//
//  NotificationView.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/9/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class NotificationView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    
    @IBOutlet weak var textsLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var textsRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var emojiLeftConstaint: NSLayoutConstraint!
    
    func setNotification(_ notification: NotificationProtocol) {
        titleLabel.text = notification.title
        emojiLabel.text = notification.emoji
        
        if let description = notification.description {
            descriptionLabel.text = description
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.text = nil
            descriptionLabel.isHidden = true
        }
        
        setupSizes()
    }
    
    private func setupSizes() {
        if UIScreen.main.bounds.width > 320 {
            textsLeftConstraint.constant = 16
            textsRightConstraint.constant = 16
            emojiLeftConstaint.constant = 16
        } else {
            textsLeftConstraint.constant = 10
            textsRightConstraint.constant = 10
            emojiLeftConstaint.constant = 10
        }
    }
    
    static func create() -> NotificationView {
        let bundle = Bundle(for: NotificationView.self)
        let views = bundle.loadNibNamed("NotificationView", owner: nil, options: nil)!
        return views[0] as! NotificationView
    }
}
