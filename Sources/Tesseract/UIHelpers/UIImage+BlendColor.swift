//
//  UIImage+BlendColor.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/24/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

extension UIImage {
    public func blendedByColor(_ color: UIColor) -> UIImage {
        UIScreen.main.scale > 1
            ? UIGraphicsBeginImageContextWithOptions(size, false, scale)
            : UIGraphicsBeginImageContext(size)
        color.setFill()
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIRectFill(bounds)
        draw(in: bounds, blendMode: .destinationIn, alpha: 1)
        let blendedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return blendedImage!
    }
}
