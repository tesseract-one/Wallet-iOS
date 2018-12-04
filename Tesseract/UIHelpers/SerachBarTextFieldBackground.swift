//
//  SerachBarTextFieldBackground.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/4/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

extension UISearchBar {
  
  private func getViewElement<T>(type: T.Type) -> T? {
    
    let svs = subviews.flatMap { $0.subviews }
    guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
    return element
  }
  
  func setTextFieldColor(color: UIColor) {
    
    if let textField = getViewElement(type: UITextField.self) {
      switch searchBarStyle {
      case .minimal:
        textField.layer.backgroundColor = color.cgColor
        textField.layer.cornerRadius = 6
        
      case .prominent, .default:
        textField.backgroundColor = color
      }
    }
  }
}
