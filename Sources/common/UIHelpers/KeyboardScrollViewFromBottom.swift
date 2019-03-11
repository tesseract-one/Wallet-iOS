//
//  KeyboardScrollViewFromBottom.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/11/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class KeyboardScrollViewFromBottom: UIViewController {
    
    private var bottomConstraintInitial: CGFloat = 0.0
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bottomConstraintInitial = self.bottomConstraint.constant
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardOpened), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardClosed), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    func moveConstraints(keyboardHeight: CGFloat?) {
        if let height = keyboardHeight {
            self.bottomConstraint.constant = self.bottomConstraintInitial + height
        } else {
           self.bottomConstraint.constant = self.bottomConstraintInitial
        }
    }
    
    @objc func onKeyboardOpened(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.layoutIfNeeded()
            moveConstraints(keyboardHeight: keyboardHeight)
            UIView.animate(withDuration: 1.0) {
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    @objc func onKeyboardClosed(notification: NSNotification) {
        self.view.layoutIfNeeded()
        moveConstraints(keyboardHeight: nil)
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

class KeyboardScrollViewFromBoth: KeyboardScrollViewFromBottom {
    
    private var topConstraintInitial: CGFloat = 0.0
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topConstraintInitial = self.topConstraint.constant
    }
    
    override func moveConstraints(keyboardHeight: CGFloat?) {
        super.moveConstraints(keyboardHeight: keyboardHeight)
        
        if let height = keyboardHeight {
            self.topConstraint.constant = self.topConstraintInitial - height
        } else {
            self.topConstraint.constant = self.topConstraintInitial
        }
    }
}
