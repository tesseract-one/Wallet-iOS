//
//  BoundleLoadXib.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/14/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import Foundation

extension Bundle {
  
  static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
    if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
      return view
    }
    
    fatalError("Could not load view with type " + NSStringFromClass(type as! AnyClass).components(separatedBy: ".").last!)
  }
}
