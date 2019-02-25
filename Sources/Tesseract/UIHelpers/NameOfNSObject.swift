//
//  NameOfNSObject.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/5/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

extension NSObject {
  var theClassName: String {
    return NSStringFromClass(type(of: self))
  }
}
