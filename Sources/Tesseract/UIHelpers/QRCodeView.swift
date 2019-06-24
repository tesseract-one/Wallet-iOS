//
//  QRCodeView.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit

class QRCodeView: RoundedImage {
    let data: Property<String> = Property("")
    private let ciFilter = CIFilter(name: "CIQRCodeGenerator")
    
    func setData(data: String) {
        self.data.send(data)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupObserver()
    }
    
    private func setupObserver() {
        data.with(weak: self)
            .map { (str, sself) -> CIImage? in
                if let data = str.data(using: .isoLatin1), let filter = sself.ciFilter {
                    filter.setValue(data, forKey: "inputMessage")
                    return filter.outputImage
                }
                return nil
            }
            .with(weak: self)
            .map { ci, sself in
                if let image = ci {
                    let scaleX = sself.bounds.width / image.extent.width
                    let scaleY = sself.bounds.height / image.extent.height
                    return image.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
                }
                return nil
            }
            .map { (ci) -> UIImage? in
                ci == nil ? nil : UIImage(ciImage: ci!)
            }
            .bind(to: reactive.image)
            .dispose(in: reactive.bag)
    }
}
