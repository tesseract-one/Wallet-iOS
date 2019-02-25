//
//  KeyboardScrollableView.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/13/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class KeyboardScrollableView: UIView {
  var initialY: CGFloat = 0.0
  
  override func awakeFromNib() {
    initialY = frame.origin.y
    NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardOpened), name: UIResponder.keyboardWillShowNotification, object: nil);
    NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardClosed), name: UIResponder.keyboardWillHideNotification, object: nil);
  }
  
  @objc func onKeyboardOpened(notification: NSNotification) {
    if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardRectangle = keyboardFrame.cgRectValue
      let keyboardHeight = keyboardRectangle.height
      UIView.animate(withDuration: 1.0) {
        self.frame.origin.y = self.initialY - keyboardHeight
      }
    }
  }
  
  @objc func onKeyboardClosed(notification: NSNotification) {
    UIView.animate(withDuration: 1.0) {
      self.frame.origin.y = self.initialY
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
