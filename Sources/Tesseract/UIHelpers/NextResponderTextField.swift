//
//  NextResponderTextField.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/12/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import Material

@objc
open class NextResponderTextField: ErrorTextField {
  
  // Properies
  //
  @IBInspectable
  open var isPlaceholderUppercasedWhenEditingIB: Bool {
    get {
      return isPlaceholderUppercasedWhenEditing
    }
    set {
      isPlaceholderUppercasedWhenEditing = newValue
    }
  }
  
  @IBInspectable
  open var placeholderActiveColorIB: UIColor {
    get {
      return placeholderActiveColor
    }
    set {
      placeholderActiveColor = newValue
    }
  }
  
  @IBInspectable
  open var placeholderNormalColorIB: UIColor {
    get {
      return placeholderNormalColor
    }
    set {
      placeholderNormalColor = newValue
    }
  }
  
  @IBInspectable
  open var placeholderFontSize: CGFloat = 14.0 {
    didSet {
      placeholderLabel.fontSize = placeholderFontSize
    }
  }
  
  @IBInspectable
  open var dividerColorIB: UIColor? {
    get {
      return dividerColor
    }
    set {
      dividerColor = newValue
    }
  }
  
  @IBInspectable
  open var dividerActiveColorIB: UIColor {
    get {
      return dividerActiveColor
    }
    set {
      dividerActiveColor = newValue
    }
  }
  
  @IBInspectable
  open var dividerNormalColorIB: UIColor {
    get {
      return dividerNormalColor
    }
    set {
      dividerNormalColor = newValue
    }
  }
  
  @IBInspectable
  open var textColorIB: UIColor? {
    get {
      return textColor
    }
    set {
      textColor = newValue
    }
  }
  
  @IBInspectable
  open var fontSize: CGFloat {
    get {
      if let font = font {
        return font.pointSize
      }
      font = UIFont.systemFont(ofSize: 14.0)
      return 14.0
    }
    set {
      font = UIFont.systemFont(ofSize: newValue)
    }
  }
  
  @IBInspectable
  open var isClearIconButtonAutoHandledIB: Bool {
    get {
      return isClearIconButtonAutoHandled
    }
    set {
      isClearIconButtonAutoHandled = newValue
    }
  }
  
  @IBInspectable
  open var clearIconButtonTintColor: UIColor = UIColor.white {
    didSet {
      if let clearIconButton = clearIconButton {
        clearIconButton.tintColor = clearIconButtonTintColor
      }
    }
  }
  
  @IBInspectable
  open var textInsetsIB: CGRect = CGRect(x: 0, y: 6.0, width: 0, height: 6.0) { // width == right, height == bottom
    didSet {
      textInsets = UIEdgeInsets(top: textInsetsIB.origin.y, left: textInsetsIB.origin.x, bottom: textInsetsIB.height, right: textInsetsIB.width)
    }
  }
  
  @IBInspectable
  open var errorColorIB: UIColor {
    get {
      return errorColor
    }
    set {
      errorColor = newValue
    }
  }
  
  @IBInspectable
  open var isErrorRevealedIB: Bool {
    get {
      return isErrorRevealed
    }
    set {
      isErrorRevealed = newValue
    }
  }
  
  /// Represents the next field. It can be any responder.
  /// If it is UIButton and enabled then the button will be tapped.
  /// If it is UIButton and disabled then the keyboard will be dismissed.
  /// If it is another implementation, it becomes first responder.
  @objc
  @IBOutlet open weak var nextResponderView: UIResponder?
  
  // Lifecycle hooks
  //
  @objc
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setUp()
  }
  
  @objc
  override public init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
  }
  
  // Private functions
  //
  private func setUp() {
    addTarget(self, action: #selector(actionKeyboardButtonTapped(sender:)), for: .editingDidEndOnExit)
    
    // We need it to wipe error text, when user start editing field. We can't do it through delegate, because parent class (TextField) use it
    if isErrorRevealedIB {
      NotificationCenter.default.addObserver(self, selector: #selector(self.beginEditing), name: UITextField.textDidBeginEditingNotification, object: self)
    }
    
    // Default values of ErrorTextField
    isPlaceholderUppercasedWhenEditingIB = true
    placeholderActiveColorIB = UIColor.init(white: 1.0, alpha: 0.5)
    placeholderNormalColorIB = UIColor.init(white: 1.0, alpha: 0.75)
    dividerColorIB = UIColor.init(red: 0.24, green: 0.24, blue: 0.24, alpha: 1.0)
    dividerActiveColorIB = UIColor.init(red: 0.24, green: 0.24, blue: 0.24, alpha: 1.0)
    dividerNormalColorIB = UIColor.init(red: 0.24, green: 0.24, blue: 0.24, alpha: 1.0)
    textColorIB = UIColor.white
    isClearIconButtonEnabled = true
    isClearIconButtonAutoHandledIB = true
    errorColorIB = UIColor.init(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
    isErrorRevealedIB = true
  }
  
  @objc private func actionKeyboardButtonTapped(sender: UITextField) {
    switch nextResponderView {
    case let button as UIButton where button.isEnabled:
      button.sendActions(for: .touchUpInside)
    case .some(let responder):
      responder.becomeFirstResponder()
    default:
      resignFirstResponder()
    }
  }
  
  @objc private func beginEditing() {
    if isErrorRevealedIB, error != "" {
      error = ""
    }
  }
  
  deinit {
    if isErrorRevealedIB {
     NotificationCenter.default.removeObserver(self)
    }
  }
}
