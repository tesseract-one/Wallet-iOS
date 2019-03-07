//
//  NextResponderTextView.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/20/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class NextResponderTextView: CustomInsetsTextView, UITextViewDelegate {
  
  // MARK: Inspectable vars
  // Placeholder
  @IBInspectable
  var placeholder: String? {
    get {
      var placeholderText: String?
      
      if let placeholderLabel = viewWithTag(100) as? UILabel {
        placeholderText = placeholderLabel.text
      }
      
      return placeholderText
    }
    set {
      if let placeholderLabel = viewWithTag(100) as! UILabel? {
        placeholderLabel.text = newValue
        placeholderLabel.sizeToFit()
      } else {
        addPlaceholder(newValue!)
      }
    }
  }
  
  @IBInspectable
  var placeholderColor: UIColor {
    get {
      if let placeholderLabel = viewWithTag(100) as! UILabel? {
        return placeholderLabel.textColor
      }
      return UIColor(white: 100.0 / 255.0, alpha: 1.0)
    }
    set {
      if let placeholderLabel = viewWithTag(100) as! UILabel? {
        placeholderLabel.textColor = placeholderColor
      }
    }
  }
  
  // Error
  @IBInspectable
  var error: String? {
    get {
      var errorText: String?
      
      if let errorLabel = viewWithTag(200) as? UILabel {
        errorText = errorLabel.text
      }
      
      return errorText
    }
    set {
      if let errorLabel = viewWithTag(200) as! UILabel? {
        errorLabel.text = newValue
        errorLabel.sizeToFit()
      } else {
        addError(newValue!)
      }
    }
  }
  
  @IBInspectable
  var errorColor: UIColor {
    get {
      if let errorLabel = viewWithTag(200) as! UILabel? {
        return errorLabel.textColor
      }
      return UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
    }
    set {
      if let errorLabel = viewWithTag(200) as! UILabel? {
        errorLabel.textColor = errorColor
      }
    }
  }
  
  @IBInspectable
  var errorFontSize: CGFloat {
    get {
      if let errorLabel = viewWithTag(200) as! UILabel? {
        return errorLabel.fontSize
      }
      return 12.0
    }
    set {
      if let errorLabel = viewWithTag(200) as! UILabel? {
        errorLabel.fontSize = newValue
      }
    }
  }
  
  @IBInspectable
  var errorOffset: CGFloat = 8.0 {
    didSet {
      resizeError()
    }
  }
  
  // Resize the placeholder when the UITextView bounds change
  override open var bounds: CGRect {
    didSet {
      self.resizePlaceholder()
      self.resizeError()
    }
  }
  
  // MARK: Outlets
  //
  @objc
  @IBOutlet open weak var nextResponderView: UIResponder?
  
  // MARK: Lifecycle
  //
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // MARK: Private functions
  // When the UITextView did change, show or hide the label based on if the UITextView is empty or not
  // - Parameter textView: The UITextView that got updated
  public func textViewDidChange(_ textView: UITextView) {
    if let placeholderLabel = viewWithTag(100) as? UILabel {
      placeholderLabel.isHidden = text.count > 0
    }
    if let errorLabel = viewWithTag(200) as? UILabel {
      errorLabel.isHidden = text.count > 0
      if text.count > 0, errorLabel.text != "" {
        errorLabel.text = ""
      }
    }
  }
  
  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      actionKeyboardButtonTapped(sender: self)
      return false
    }
    return true
  }
  
  // Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
  private func resizePlaceholder() {
    if let placeholderLabel = viewWithTag(100) as! UILabel? {
      let labelX = textContainerInset.left + textContainer.lineFragmentPadding
      let labelY = textContainerInset.top + font!.ascender - font!.capHeight
      let labelWidth = frame.width - (labelX * 2)
      let labelHeight = placeholderLabel.font.capHeight //placeholderLabel.frame.height
      
      placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
    }
  }
  
  // Adds a placeholder UILabel to this UITextView
  private func addPlaceholder(_ placeholderText: String) {
    let placeholderLabel = UILabel()
    
    placeholderLabel.text = placeholderText
    placeholderLabel.sizeToFit()
    
    placeholderLabel.font = font
    placeholderLabel.textColor = placeholderColor
    placeholderLabel.tag = 100
    
    placeholderLabel.isHidden = text.count > 0
    
    addSubview(placeholderLabel)
    resizePlaceholder()
    delegate = self
  }
  
  private func resizeError() {
    if let errorLabel = viewWithTag(200) as! UILabel? {
      let labelX = textContainerInset.left + textContainer.lineFragmentPadding
      let labelY = bounds.height - textContainerInset.bottom + errorOffset
      let labelWidth = frame.width - (labelX * 2)
      let labelHeight = errorLabel.fontSize //placeholderLabel.frame.height
      
      errorLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
    }
  }
  
  private func addError(_ errorText: String) {
    let errorLabel = UILabel()
    clipsToBounds = false
    
    errorLabel.text = errorText
    errorLabel.sizeToFit()
    
    errorLabel.font = UIFont.systemFont(ofSize: errorFontSize)
    errorLabel.textColor = errorColor
    errorLabel.tag = 200
    
    addSubview(errorLabel)
    resizeError()
    delegate = self
  }
  
  @objc private func actionKeyboardButtonTapped(sender: UITextView) {
    switch nextResponderView {
    case let button as UIButton where button.isEnabled:
      button.sendActions(for: .touchUpInside)
    case .some(let responder):
      responder.becomeFirstResponder()
    default:
      resignFirstResponder()
    }
  }
}
