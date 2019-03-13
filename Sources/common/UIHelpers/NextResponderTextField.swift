//
//  NextResponderTextField.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/12/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import MaterialTextField

@objc
open class NextResponderTextField: MFTextField {
  
  @objc
  @IBOutlet open weak var nextResponderView: UIResponder?
  
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

  private func setUp() {
    addTarget(self, action: #selector(actionKeyboardButtonTapped(sender:)), for: .editingDidEndOnExit)
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
}
