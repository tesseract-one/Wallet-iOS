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
  open var isPlaceholderUppercasedWhenEditingIB: Bool = true {
    didSet {
      updateIsPlaceholderUppercasedWhenEditing()
    }
  }
  
  @IBInspectable
  open var placeholderActiveColorIB = UIColor.init(white: 1.0, alpha: 0.5) {
    didSet {
      updatePlaceholderActiveColor()
    }
  }
  
  @IBInspectable
  open var placeholderNormalColorIB: UIColor = UIColor.init(white: 1.0, alpha: 0.75) {
    didSet {
      updatePlaceholderNormalColor()
    }
  }
  
  @IBInspectable
  open var placeholderFontSize: CGFloat = 14.0 {
    didSet {
      updatePlaceholderFontSize()
    }
  }
  
  @IBInspectable
  open var dividerColorIB: UIColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) {
    didSet {
      updateDividerColor()
    }
  }
  
  @IBInspectable
  open var dividerActiveColorIB: UIColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) {
    didSet {
      updateDividerActiveColor()
    }
  }
  
  @IBInspectable
  open var dividerNormalColorIB: UIColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) {
    didSet {
      updateDividerNormalColor()
    }
  }
  
  @IBInspectable
  open var textColorIB: UIColor = UIColor.white {
    didSet {
      updateTextColor()
    }
  }
  
  @IBInspectable
  open var fontSize: CGFloat = 14.0 {
    didSet {
      updateFontSize()
    }
  }
  
  @IBInspectable
  open var isClearIconButtonEnabledIB: Bool = true {
    didSet {
      updateIsClearIconButtonEnabled()
    }
  }
  
  @IBInspectable
  open var isClearIconButtonAutoHandledIB: Bool = true {
    didSet {
      updateIsClearIconButtonAutoHandled()
    }
  }
  
  @IBInspectable
  open var clearIconButtonTintColor: UIColor = UIColor.white {
    didSet {
      updateClearIconButtonTintColor()
    }
  }
  
  @IBInspectable
  open var textInsetsIB: CGRect = CGRect(x: 0, y: 6.0, width: 0, height: 6.0) { // width == right, height == bottom
    didSet {
      updateTextInsets()
    }
  }
  
  @IBInspectable
  open var errorColorIB: UIColor = UIColor.init(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0) {
    didSet {
      updateErrorColor()
    }
  }
  
  @IBInspectable
  open var isErrorRevealedIB: Bool = true {
    didSet {
      updateIsErrorRevealed()
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
    
    initDefaultValues()
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

// Functions which updates props in TextField class
//
private extension NextResponderTextField {
  // If user didn't update corresponding value in Interface Builder, the default value didn't set.
  func initDefaultValues() {
    updateIsPlaceholderUppercasedWhenEditing()
    updatePlaceholderActiveColor()
    updatePlaceholderNormalColor()
    updatePlaceholderFontSize()
    updateDividerColor()
    updateDividerActiveColor()
    updateDividerNormalColor()
    updateTextColor()
    updateFontSize()
    updateIsClearIconButtonEnabled()
    updateIsClearIconButtonAutoHandled()
    updateClearIconButtonTintColor()
    updateTextInsets()
    updateErrorColor()
    updateIsErrorRevealed()
  }
  
  func updatePlaceholderActiveColor() {
    placeholderActiveColor = placeholderActiveColorIB
  }
  
  func updateIsPlaceholderUppercasedWhenEditing() {
    isPlaceholderUppercasedWhenEditing = isPlaceholderUppercasedWhenEditingIB
  }
  
  func updatePlaceholderNormalColor() {
    placeholderNormalColor = placeholderNormalColorIB
  }
  
  func updatePlaceholderFontSize() {
    placeholderLabel.fontSize = placeholderFontSize
  }
  
  func updateDividerColor() {
    dividerColor = dividerColorIB
  }
  
  func updateDividerActiveColor() {
    dividerActiveColor = dividerActiveColorIB
  }
  
  func updateDividerNormalColor() {
    dividerNormalColor = dividerNormalColorIB
  }
  
  func updateTextColor() {
    textColor = textColorIB
  }
  
  func updateFontSize() {
    font = UIFont.systemFont(ofSize: fontSize)
  }
  
  func updateIsClearIconButtonEnabled() {
    isClearIconButtonEnabled = isClearIconButtonEnabledIB
  }
  
  func updateIsClearIconButtonAutoHandled() {
    isClearIconButtonAutoHandled = isClearIconButtonAutoHandledIB
  }
  
  func updateClearIconButtonTintColor() {
    if let clearIconButton = clearIconButton {
      clearIconButton.tintColor = clearIconButtonTintColor
    }
  }
  
  func updateTextInsets() {
    textInsets = UIEdgeInsets(top: textInsetsIB.origin.y, left: textInsetsIB.origin.x, bottom: textInsetsIB.height, right: textInsetsIB.width)
  }
  
  func updateErrorColor() {
    errorColor = errorColorIB
  }
  
  func updateIsErrorRevealed() {
    isErrorRevealed = isErrorRevealedIB
  }
}
