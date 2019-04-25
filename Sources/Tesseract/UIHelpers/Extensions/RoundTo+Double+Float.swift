//
//  Round.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/30/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import CoreGraphics

extension Double {
  /// Rounds the double to decimal places value
  func rounded(toPlaces places:Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}

extension CGFloat {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
