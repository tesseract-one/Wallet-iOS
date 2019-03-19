//
//  NextResponderTextView.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/20/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

@IBDesignable
class NextResponderTextView: TextView {
    
    @objc
    @IBOutlet open weak var nextResponderView: UIResponder?
    
    @objc
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self.textView)
    }
    
    @objc private func textDidChange(nofitication: NSNotification) {
        if textView.text.last == "\n" {
            textView.text = String(textView.text.dropLast())
            actionKeyboardButtonTapped()
        }
    }

    @objc private func actionKeyboardButtonTapped() {
        switch nextResponderView {
        case let button as UIButton where button.isEnabled:
            button.sendActions(for: .touchUpInside)
        case .some(let responder):
            responder.becomeFirstResponder()
        default:
            resignFirstResponder()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
