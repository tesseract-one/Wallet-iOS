//
//  MaterialTextField.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/15/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
class MaterialTextField: UITextField {
    
    // MARK: Properties
    private let animationDuration: TimeInterval = 0.25
    private let placeholderLineOffsetX: CGFloat = 4.0
    
    @IBInspectable var textPadding: CGSize = CGSize(width: 16.0, height: 8.0)
    
    override var text: String? {
        didSet {
            if !shouldAnimateToTop { animatePlaceholderToBottom(animated: true) }
        }
    }
    
    // placeholder
    @IBInspectable var placeholderAnimatesOnFocus: Bool = true
    @IBInspectable var placeholderActiveFontSize: CGFloat = 10.0
    @IBInspectable var placeholderActiveFontColor: UIColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
    
    @IBInspectable var placeholderText: String? { // can't use default placeholder, coz we can't animate it without deleting placeholder text
        didSet { updatePlaceholderText(text: placeholderText) }
    }
    @IBInspectable var placeholderFontName: String = "SFProDisplay-Semibold" {
        didSet { placeholderLayer?.font = placeholderFont }
    }
    @IBInspectable var placeholderColor: UIColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0) {
        didSet { placeholderLayer?.foregroundColor = placeholderColor.cgColor }
    }
    
    private var placeholderFont: UIFont {
        if (text?.count ?? 0 > 0) || (placeholderAnimatesOnFocus && isFirstResponder) {
            return UIFont(name: placeholderFontName, size: placeholderActiveFontSize)!
        }
        return UIFont(name: placeholderFontName, size: font!.pointSize)!
    }
    private var placeholderScaleCoef: CGFloat {
        return placeholderActiveFontSize / placeholderLayer!.fontSize
    }
    private var shouldAnimateToTop: Bool {
        let isEmpty = text == nil ? true : text!.count == 0
        return !isEmpty || isFirstResponder
    }
    
    private var placeholderLayer: CATextLayer? = nil
    private var placeholderIsAnimating: Bool = false
    
    // error
    @IBInspectable var errorPadding: CGSize = CGSize(width: 0.0, height: 4.5)
    
    @IBInspectable var errorFontName: String = ".SFUIText" {
        didSet { errorLayer.font = UIFont(name: errorFontName, size: errorFontSize) }
    }
    @IBInspectable var errorFontSize: CGFloat = 10.0 {
        didSet { errorLayer.fontSize = errorFontSize }
    }
    @IBInspectable var errorColor: UIColor = UIColor(red: 255/255, green: 59/255, blue: 49/255, alpha: 1.0) {
        didSet { errorLayer.foregroundColor = errorColor.cgColor }
    }
    
    public var error: String = "" {
        didSet {
            if oldValue == "" && error == "" { return } // for init state
            errorLayer.string = error
            hasError ? showError(animated: true) : hideError(animated: true)
        }
    }
    
    private var hasError: Bool {
        return error != ""
    }
    
    private var errorLayer = CATextLayer()
    private var errorIsAnimating: Bool = false
    
    // background layer
    override var backgroundColor: UIColor? {
        get {
            return backgroundLayer.backgroundColor != nil
                ? UIColor(cgColor: backgroundLayer.backgroundColor!)
                : nil
        }
        set {
            backgroundLayer.backgroundColor = newValue?.cgColor
            placeholderLine.backgroundColor = newValue?.cgColor
        }
    }
    
    @IBInspectable override var borderColor: UIColor? {
        didSet { backgroundLayer.borderColor = borderColor?.cgColor }
    }
    @IBInspectable override var borderWidth: CGFloat {
        get { return backgroundLayer.borderWidth }
        set {
            backgroundLayer.borderWidth = newValue
            placeholderLine.frame.size.height = newValue
        }
    }
    @IBInspectable override var cornerRadius: CGFloat {
        get { return backgroundLayer.cornerRadius }
        set { backgroundLayer.cornerRadius = newValue }
    }
    
    private let backgroundLayer = CALayer()
    private let placeholderLine = CALayer()
    
    // clear button
    @IBInspectable var clearButtonColor: UIColor = .white {
        didSet { setupClearButton() }
    }
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        setupTextField()
        setupBackgroundLayer()
        setupErrorLayer()
        setupClearButton()
    }
    
    // MARK: Setup
    private func setupTextField() {
        clipsToBounds = false
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.onTakeFocus), name: UITextField.textDidBeginEditingNotification, object: self
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.onLostFocus), name: UITextField.textDidEndEditingNotification, object: self
        )
    }
    
    private func setupBackgroundLayer() {
        backgroundLayer.backgroundColor = backgroundColor?.cgColor
        backgroundLayer.borderColor = borderColor?.cgColor
        backgroundLayer.borderWidth = borderWidth
        backgroundLayer.cornerRadius = cornerRadius
        backgroundLayer.zPosition = -2
        
        updateBackgoundLayerFrame()
        
        layer.addSublayer(backgroundLayer)
    }
    
    private func setupPlaceholderLayer() {
        placeholderLayer = CATextLayer()
        placeholderLayer!.foregroundColor = placeholderColor.cgColor
        placeholderLayer!.string = placeholderText
        placeholderLayer!.alignmentMode = textAlignment.convertToCATextLayerAlignmentMode()
        placeholderLayer!.font = placeholderFont
        placeholderLayer!.fontSize = font!.pointSize
        placeholderLayer!.allowsFontSubpixelQuantization = true
        placeholderLayer!.contentsScale = UIScreen.main.scale
        placeholderLayer!.zPosition = 0
        
        let frameSize = placeholderLayer!.calculateFrameSize(maxWidth: (bounds.width - textPadding.width * 2))
        
        placeholderLayer!.frame = CGRect(
            x: textPadding.width, y: textPadding.height, width: frameSize.width, height: frameSize.height
        )
        
        layer.addSublayer(placeholderLayer!)
        
        setupPlaceholderLine()
    }
    
    private func setupPlaceholderLine() {
        placeholderLine.frame = CGRect(
            x: placeholderLayer!.frame.origin.x - placeholderLineOffsetX, y: 0,
            width: placeholderLayer!.frame.width * placeholderScaleCoef + 2 * placeholderLineOffsetX, height: borderWidth
        )
        placeholderLine.zPosition = -1

        animatePlaceholderLine(isAnimateToTop: false)
    
        layer.addSublayer(placeholderLine)
    }
    
    private func setupErrorLayer() {
        errorLayer.isWrapped = true
        errorLayer.foregroundColor = errorColor.cgColor
        errorLayer.string = error
        errorLayer.alignmentMode = textAlignment.convertToCATextLayerAlignmentMode()
        errorLayer.font = UIFont(name: errorFontName, size: errorFontSize)
        errorLayer.fontSize = errorFontSize
        errorLayer.opacity = 0.0
        errorLayer.allowsFontSubpixelQuantization = true
        errorLayer.contentsScale = UIScreen.main.scale
        errorLayer.zPosition = 0
        
        let frameSize = errorLayer.calculateFrameSize(
            maxWidth: (bounds.width - textPadding.width * 2 - errorPadding.width * 2)
        )
        
        errorLayer.frame = CGRect(
            x: textPadding.width + errorPadding.width, y: 0,
            width: frameSize.width, height: frameSize.height
        )
        
        updateErrorFrameY(isHidden: true)
        
        layer.addSublayer(errorLayer)
    }
    
    private func setupClearButton() {
        guard let button = value(forKey: "_clearButton") as? UIButton else { return }
        let image = UIImage(named: "clear")
        button.setImage(image?.blendedByColor(clearButtonColor) ?? button.image(for: .normal), for: .normal)
        button.setImage(image?.blendedByColor(clearButtonColor) ?? button.image(for: .highlighted), for: .highlighted)
    }
    
    private func updatePlaceholderFrameOrigin() {
        guard let placeholderLayer = placeholderLayer else { return }

        placeholderLayer.frame.origin.y = shouldAnimateToTop ? -placeholderLayer.frame.size.height / 2 : textPadding.height
        placeholderLayer.frame.origin.x = textPadding.width // should update it, beacause transform changes it
    }

    private func animatePlaceholder(isAnimateToTop: Bool) {
        guard let placeholderLayer = placeholderLayer else { return }
        
        if isAnimateToTop {
            placeholderLayer.setAffineTransform(CGAffineTransform(scaleX: placeholderScaleCoef, y: placeholderScaleCoef))
            placeholderLayer.foregroundColor = placeholderActiveFontColor.cgColor
        } else {
            placeholderLayer.setAffineTransform(.identity)
            placeholderLayer.foregroundColor = placeholderColor.cgColor
        }
    }
    
    private func animatePlaceholderLine(isAnimateToTop: Bool) {
        if isAnimateToTop {
            placeholderLine.frame.size.width = placeholderLayer!.frame.width + 2 * placeholderLineOffsetX
            placeholderLine.frame.origin.x = textPadding.width - placeholderLineOffsetX
        } else {
            placeholderLine.frame.size.width = 0
            placeholderLine.frame.origin.x = textPadding.width + (placeholderLayer!.frame.width * placeholderScaleCoef + 2 * placeholderLineOffsetX) / 2
        }
    }
    
    private func updateBackgoundLayerFrame() {
        backgroundLayer.frame = calculateBackgroundFrame()
    }
    
    private func updatePlaceholderText(text: String?) {
        guard let text = text else {
            placeholderLayer?.removeFromSuperlayer()
            placeholderLayer = nil
            return
        }
        
        placeholderLayer != nil
            ? placeholderLayer!.string = text
            : setupPlaceholderLayer()
    }
    
    private func updateErrorFrameSize() {
        errorLayer.frame.size = errorLayer.calculateFrameSize(
            maxWidth: (bounds.width - textPadding.width * 2 - errorPadding.width * 2)
        )
    }
    
    private func updateErrorFrameY(isHidden: Bool) {
        let backgroundFrame = calculateBackgroundFrame()

        errorLayer.frame.origin.y = isHidden
            ? backgroundFrame.maxY - errorLayer.frame.height
            : backgroundFrame.maxY + errorPadding.height
    }
    
    private func animatePlaceholderToTop(animated: Bool) {
        if placeholderIsAnimating { return }
        
        guard animated else {
            animatePlaceholder(isAnimateToTop: true)
            animatePlaceholderLine(isAnimateToTop: true)
            updatePlaceholderFrameOrigin()
            return
        }
        
        placeholderIsAnimating = true
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
        CATransaction.setCompletionBlock {
            self.placeholderIsAnimating = false
            self.layoutSubviews()
            if !self.shouldAnimateToTop { self.animatePlaceholderToBottom(animated: true) }
        }
        
        animatePlaceholder(isAnimateToTop: true)
        animatePlaceholderLine(isAnimateToTop: true)
        updatePlaceholderFrameOrigin()
        
        CATransaction.commit()
    }
    
    private func animatePlaceholderToBottom(animated: Bool) {
        if placeholderIsAnimating { return }
        
        guard animated else {
            animatePlaceholder(isAnimateToTop: false)
            animatePlaceholderLine(isAnimateToTop: false)
            updatePlaceholderFrameOrigin()
            return
        }
        
        placeholderIsAnimating = true
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
        CATransaction.setCompletionBlock {
            self.placeholderIsAnimating = false
            self.layoutSubviews()
            if self.shouldAnimateToTop { self.animatePlaceholderToTop(animated: true) }
        }

        animatePlaceholder(isAnimateToTop: false)
        animatePlaceholderLine(isAnimateToTop: false)
        updatePlaceholderFrameOrigin()

        CATransaction.commit()
    }

    private func showError(animated: Bool) {
        if errorIsAnimating { return }

        invalidateIntrinsicContentSize()

        guard animated else {
            errorLayer.opacity = 1.0
            superview?.layoutSubviews()
            updateBackgoundLayerFrame()
            updateErrorFrameY(isHidden: false)
            return
        }

        errorIsAnimating = true

        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
        CATransaction.setCompletionBlock {
            self.errorIsAnimating = false
            self.layoutSubviews()
            if !self.hasError { self.hideError(animated: true) }
        }
        
        UIView.animate(withDuration: animationDuration, animations: { self.superview?.layoutSubviews() })
        
        updateErrorFrameSize()
        updateErrorFrameY(isHidden: true)

        errorLayer.opacity = 1.0
        updateBackgoundLayerFrame()
        updateErrorFrameY(isHidden: false)

        CATransaction.commit()
    }
    
    private func hideError(animated: Bool) {
        if errorIsAnimating { return }
        
        invalidateIntrinsicContentSize()
        
        guard animated else {
            superview?.layoutSubviews()
            errorLayer.opacity = 0.0
            updateErrorFrameSize()
            updateErrorFrameY(isHidden: true)
            return
        }

        errorIsAnimating = true
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
        CATransaction.setCompletionBlock {
            self.errorIsAnimating = false
            self.updateErrorFrameSize()
            self.layoutSubviews()
            if self.hasError { self.showError(animated: true) }
        }
        
        UIView.animate(withDuration: animationDuration, animations: { self.superview?.layoutSubviews() })
        
        updateErrorFrameY(isHidden: false)
        
        errorLayer.opacity = 0.0
        updateErrorFrameY(isHidden: true)
        updateBackgoundLayerFrame()
        
        CATransaction.commit()
    }
    
    private func calculateBackgroundFrame() -> CGRect {
        let textHeight = font?.lineHeight ?? 15.0
        return CGRect(x: 0, y: 0, width: bounds.width, height: textHeight + textPadding.height * 2)
    }
    
    private func errorSpaceHeight() -> CGFloat {
        return hasError ? errorLayer.frame.height + errorPadding.height : 0.0
    }
    
    private func clearButtonSpaceWidth() -> CGFloat {
        return clearButtonMode != .never ? clearButtonRect(forBounds: bounds).width : 0.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !errorIsAnimating && !placeholderIsAnimating {
            updateErrorFrameY(isHidden: false)
            updateBackgoundLayerFrame()
            updatePlaceholderFrameOrigin()
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        let height = calculateBackgroundFrame().maxY + errorSpaceHeight()
        return CGSize(width: self.bounds.size.width, height: height)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect (
            x: bounds.origin.x + textPadding.width,
            y: bounds.origin.y + textPadding.height,
            width: bounds.size.width - textPadding.width * 2 - clearButtonSpaceWidth(),
            height: bounds.size.height - textPadding.height * 2 - errorSpaceHeight()
        )
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds)
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let oldRect = super.clearButtonRect(forBounds: bounds)
        return CGRect(
            x: frame.width - oldRect.width - textPadding.width,
            y: oldRect.minY,
            width: oldRect.width,
            height: oldRect.height
        )
    }
    
    @objc
    private func onTakeFocus() {
        if placeholderAnimatesOnFocus {
            animatePlaceholderToTop(animated: true)
        }
        backgroundLayer.borderColor = tintColor.cgColor
    }
    
    @objc
    private func onLostFocus() {
        if placeholderAnimatesOnFocus && !shouldAnimateToTop {
            animatePlaceholderToBottom(animated: true)
        }
        backgroundLayer.borderColor = borderColor?.cgColor
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

