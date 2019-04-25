//
//  CATextLayer+Size.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/16/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import UIKit

extension CATextLayer {
    func calculateFrameSize(maxWidth: CGFloat) -> CGSize {
        let attrString: NSAttributedString
        switch self.string {
        case let attr as NSAttributedString: attrString = attr
        case let string as String:
            var attributes: [NSAttributedString.Key: Any] = [:]
            if let font = self.font {
                attributes[.font] = font as! UIFont
            }
            attrString = NSAttributedString(string: string, attributes: attributes)
        default: return CGSize.zero
        }
    
        let typesetter = CTTypesetterCreateWithAttributedString(attrString)
        
        var offset = 0, length = 0
        var y: CGFloat = 0
        var lineCount = 0
        var newWidth = Double(maxWidth)
        
        repeat {
            length = CTTypesetterSuggestLineBreak(typesetter, offset, Double(maxWidth))
            let line = CTTypesetterCreateLine(typesetter, CFRangeMake(offset, length))
            
            var ascent: CGFloat = 0, descent: CGFloat = 0, leading: CGFloat = 0
            newWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            
            offset += length
            y += ascent + descent + leading
            lineCount += 1
        } while (offset < attrString.length)
        
        return lineCount == 1
            ? CGSize(width: CGFloat(newWidth), height: y.rounded(toPlaces: 2))
            : CGSize(width: maxWidth, height: y.rounded(toPlaces: 2))
    }
}
