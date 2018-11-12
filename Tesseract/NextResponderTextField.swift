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
open class NextResponderTextField: TextField {
  
  /// Represents the next field. It can be any responder.
  /// If it is UIButton and enabled then the button will be tapped.
  /// If it is UIButton and disabled then the keyboard will be dismissed.
  /// If it is another implementation, it becomes first responder.
  @objc
  @IBOutlet open weak var nextResponderView: UIResponder?
  
  /**
   Creates a new view with the passed coder.
   :param: aDecoder The a decoder
   :returns: the created new view.
   */
  @objc
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setUp()
  }
  
  /**
   Creates a new view with the passed frame.
   :param: frame The frame
   :returns: the created new view.
   */
  @objc
  override public init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
  }
  
  /**
   Sets up the view.
   */
  private func setUp() {
    addTarget(self, action: #selector(actionKeyboardButtonTapped(sender:)), for: .editingDidEndOnExit)
  }
  
  /**
   Action keyboard button tapped.
   :param: sender The sender of the action parameter.
   */
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
}
