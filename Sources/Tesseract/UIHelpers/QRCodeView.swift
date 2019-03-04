//
//  QRCodeView.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit

class QRCodeView: UIImageView {
    let data: Property<String> = Property("")
    private let ciFilter = CIFilter(name: "CIQRCodeGenerator")
    
    func setData(data: String) {
        self.data.next(data)
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
                if let data = str.data(using: .ascii), let filter = sself.ciFilter {
                    filter.setValue(data, forKey: "inputMessage")
                    return filter.outputImage
                }
                return nil
            }
            .map { (ci) -> UIImage? in
                ci == nil ? nil : UIImage(ciImage: ci!, scale: UIScreen.main.scale, orientation: .up)
            }
            .bind(to: reactive.image)
            .dispose(in: reactive.bag)
    }
}
