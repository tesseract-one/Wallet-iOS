//
//  VerticallyCenteredTextLayer.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/6/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class VerticallyCenteredTextLayer : CATextLayer {
    
    // REF: http://lists.apple.com/archives/quartz-dev/2008/Aug/msg00016.html
    // CREDIT: David Hoerl - https://github.com/dhoerl
    // USAGE: To fix the vertical alignment issue that currently exists within the CATextLayer class.
    
    override func draw(in ctx: CGContext) {
        let fontSize = self.fontSize
        let height = self.bounds.size.height
        let deltaY = (height-fontSize)/2 - fontSize/10
        
        ctx.saveGState()
        ctx.translateBy(x: 0.0, y: deltaY)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
}
