//
//  KeyboardScrollView.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/11/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class KeyboardScrollView: UIViewController {
    
    private var bottomConstraintInitial: CGFloat = 0.0
    private var topConstraintInitial: CGFloat = 0.0
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint?
    @IBOutlet weak var topConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomConstraintInitial = bottomConstraint != nil ? bottomConstraint!.constant : 0.0
        topConstraintInitial = topConstraint != nil ? topConstraint!.constant : 0.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardOpened), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardClosed), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    func moveConstraints(keyboardHeight: CGFloat?) {
        if let height = keyboardHeight {
            if let bottomConstraint = bottomConstraint {
                bottomConstraint.constant = bottomConstraintInitial + height
            }
            if let topConstraint = topConstraint {
                topConstraint.constant = topConstraintInitial - height
            }
        } else {
            if let bottomConstraint = bottomConstraint  {
                bottomConstraint.constant = bottomConstraintInitial
            }
            if let topConstraint = topConstraint {
                topConstraint.constant = topConstraintInitial
            }
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
