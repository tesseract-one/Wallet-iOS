//
//  KeyboardInputScrollView.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/13/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class KeyboardInputScrollView: UIScrollView {
  
  private func attachToNotifications(view: UIView) {
    if let tf = view as? UITextField {
      NotificationCenter.default.addObserver(self, selector: #selector(self.beginEditing), name: UITextField.textDidBeginEditingNotification, object: tf)
    }
    for subview in view.subviews {
      attachToNotifications(view: subview)
    }
  }
  
  @objc private func beginEditing(notification: Notification) {
    let textField = notification.object! as! UITextField
    let position = textField.convert(CGPoint.zero, to: self)
    
    // This func calls before onKeyboardOpened func, so we need to use async to get correct contentInsets
    DispatchQueue.main.asyncAfter(deadline: .now()) {
      let centerOfVisibleRect = (self.contentSize.height - self.contentInset.bottom) / 2
      self.setContentOffset(CGPoint(x: 0, y: position.y - centerOfVisibleRect + textField.bounds.height / 2), animated: true)
    }
  }
  
  @objc func onKeyboardOpened(notification: NSNotification) {
    if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardRectangle = keyboardFrame.cgRectValue
      let keyboardHeight = keyboardRectangle.height
      let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
      contentInset = contentInsets
      scrollIndicatorInsets = contentInsets
    }
  }

  override func awakeFromNib() {
    attachToNotifications(view: self)
    NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardOpened), name: UIResponder.keyboardWillShowNotification, object: nil);
    NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardClosed), name: UIResponder.keyboardWillHideNotification, object: nil);
  }
  
  @objc private func onKeyboardClosed(notification: NSNotification) {
    contentInset = .zero
    scrollIndicatorInsets = .zero
    setContentOffset(CGPoint(x: contentOffset.x, y: -contentInset.top), animated: true)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
