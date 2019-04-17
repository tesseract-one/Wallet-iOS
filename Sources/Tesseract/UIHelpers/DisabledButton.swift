//
//  DisabledButton.swift
//  Tesseract
//
//  Created by Yehor Popovych on 4/17/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

@IBDesignable
class DisabledButton: UIButton {
    private var originalBgColor: UIColor? = nil
    private var originalTitleColor: UIColor? = nil
    private var isInitialized: Bool = false
    private var isCopied: Bool = false
    
    @IBInspectable
    var disabledBackgroundColor: UIColor? = nil {
        didSet {
            isEnabled ? enable() : disable()
        }
    }
    
    @IBInspectable
    var disabledTitleColor: UIColor? = nil {
        didSet {
            isEnabled ? enable() : disable()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            isEnabled ? enable() : disable()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isInitialized = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isInitialized = true
        let _ = initialize()
        isEnabled ? enable() : disable()
    }
    
    private func enable() {
        guard initialize() else { return }
        setTitleColor(originalTitleColor, for: .normal)
        backgroundColor = originalBgColor
    }
    
    private func disable() {
        guard initialize() else { return }
        setTitleColor(disabledTitleColor, for: .disabled)
        backgroundColor = disabledBackgroundColor
    }
    
    private func initialize() -> Bool {
        guard  isInitialized else { return false }
        guard !isCopied else { return true }
        originalBgColor = backgroundColor
        originalTitleColor = titleColor(for: .normal)
        isCopied = true
        return true
    }
}
