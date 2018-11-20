//
//  KeyboardScrollViewToTop.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/20/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class KeyboardScrollViewToTop: UIScrollView {
  
  @IBOutlet open weak var scrollableView: UIView!

  override func awakeFromNib() {
    NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardOpened), name: UIResponder.keyboardWillShowNotification, object: nil);
    NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardClosed), name: UIResponder.keyboardWillHideNotification, object: nil);
  }
  
  @objc func onKeyboardOpened(notification: NSNotification) {
    if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardRectangle = keyboardFrame.cgRectValue
      let keyboardHeight = keyboardRectangle.height
      let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
      contentInset = contentInsets
      scrollIndicatorInsets = contentInsets
      
      let position = scrollableView.convert(CGPoint.zero, to: self)
      setContentOffset(CGPoint(x: 0, y: position.y), animated: true)
    }
  }
  
  @objc func onKeyboardClosed(notification: NSNotification) {
    contentInset = .zero
    scrollIndicatorInsets = .zero
    // -1 to trigger appearence of large title on navigtaion tab bar
    setContentOffset(CGPoint(x: contentOffset.x, y: -1), animated: true)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
