//
//  GradientButton.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/6/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

@IBDesignable
class GradientButton: UIButton {
    
    @IBInspectable var fromColor: UIColor = UIColor.white {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var fromColorAlpha: CGFloat = 1.0 {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var toColorAlpha: CGFloat = 1.0 {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var toColor: UIColor = UIColor.clear {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var startPoint: CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            gradientLayer.startPoint = startPoint
        }
    }
    
    @IBInspectable var endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5) {
        didSet {
            gradientLayer.endPoint = endPoint
        }
    }
    
    @IBInspectable var horizontal: Bool = false {
        didSet {
            gradientLayer.startPoint = horizontal ? CGPoint(x: 0.0, y: 0.5) : CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = horizontal ? CGPoint(x: 1.0, y: 0.5) : CGPoint(x: 0.5, y: 1.0)
        }
    }
    
    @IBInspectable var gradientOpacity: Float = 1 {
        didSet {
            gradientLayer.opacity = gradientOpacity
        }
    }
    
    let gradientLayer: CAGradientLayer = CAGradientLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = cornerRadius // kludge for rounded buttons
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        layer.insertSublayer(gradientLayer, at: 0)
        
        addObserver(self, forKeyPath: "bounds", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.initial], context: nil)
    }
    
    func updateGradient() {
        gradientLayer.colors = [fromColor.withAlphaComponent(fromColorAlpha).cgColor, toColor.withAlphaComponent(toColorAlpha).cgColor]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    deinit {
        removeObserver(self, forKeyPath: "bounds")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "bounds") {
            gradientLayer.frame = bounds
            gradientLayer.cornerRadius = cornerRadius // kludge for rounded buttons
            return
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
}
