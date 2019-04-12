//
//  TokensViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/12/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import Foundation
import ReactiveKit
import Bond

class TokensViewController: UIViewController {

    @IBOutlet weak var askButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageCenterConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        askButton.reactive.tap.throttle(seconds: 0.1)
            .observeNext { _ in
                let url = URL(string: "https://twitter.com/tesseract_io")!
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }.dispose(in: reactive.bag)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 1.25
        paragraph.alignment = .center
        let attrString = NSAttributedString(
            string: "Our best programmers working days and\nnights to finish tokens for you. Wanna\nknow when it will be ready?",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14.0),
                .foregroundColor: UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0),
                .paragraphStyle: paragraph
            ]
        )
        
        descriptionLabel.attributedText = attrString
        
        imageCenterConstraint.constant = UIApplication.shared.statusBarFrame.size.height - 46
    }
}
