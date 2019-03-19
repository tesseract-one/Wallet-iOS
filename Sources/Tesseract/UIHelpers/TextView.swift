//
//  TextView.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/18/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

@IBDesignable
class TextView: UIView {
    private let labelFontSize: CGFloat = 12.0
    private let labelFontName: String = "SFProDisplay-Semibold"
    private let animationDuration = 0.3
    
    // MARK: TextView
    public let textView: UITextView = UITextView()
    public var textAlignment: NSTextAlignment = .left

    @IBInspectable
    open var isScrollEnabled: Bool {
        get {
            return textView.isScrollEnabled
        }
        set(isScrollEnabled) {
            textView.isScrollEnabled = isScrollEnabled
        }
    }
    @IBInspectable
    open var textViewColor: UIColor {
        get {
            return textView.textColor ?? .white
        }
        set(color) {
            textView.textColor = color
        }
    }
    @IBInspectable
    open var textViewBackground: UIColor {
        get {
            return textView.backgroundColor ?? .clear
        }
        set(color) {
            textView.backgroundColor = color
        }
    }
    @IBInspectable
    open var textViewFontName: String {
        get {
            return textView.font!.fontName
        }
        set(name) {
            updateTextViewFontName(name: name)
        }
    }
    @IBInspectable
    open var textViewFontSize: CGFloat {
        get {
            return textView.font!.pointSize
        }
        set(size) {
            updateTextViewFontSize(size: size)
        }
    }
    
    @IBInspectable
    open var textViewInsets: CGRect {
        get {
            return CGRect(x: textView.textContainerInset.left, y: textView.textContainerInset.top, width: textView.textContainerInset.right, height: textView.textContainerInset.bottom)
        }
        set (insets) {
            textView.textContainerInset = UIEdgeInsets.init(top: insets.minY, left: insets.minX, bottom: insets.height, right: insets.width)
        }
    }
    
    // MARK: Placeholder
    private var placeholderLabel: UILabel? = nil
    
    @IBInspectable var placeholder: String {
        get {
            return placeholderLabel!.text ?? ""
        }
        set(text) {
            updatePlaceholderText(text: text)
        }
    }
    // Should be inspectable
    private var placeholderFontName: String = "SFProDisplay-Semibold"
    private var placeholderFontSize: CGFloat = 13.0
    private var placeholderColor: UIColor = UIColor(red: 92/255, green: 92/255, blue: 92/255, alpha: 1.0)
    
    private var placeholderIsAnimating: Bool = false
    private var shouldAnimateToTop: Bool {
        let isEmpty = textView.text == nil ? true : textView.text.count == 0
        return !isEmpty || textView.isFirstResponder
    }
    
    // MARK: Underline
    @IBInspectable var underlineHeight: CGFloat = 1.0
    @IBInspectable var underlineEditingHeight: CGFloat = 1.75
    @IBInspectable var underlineColor: UIColor = UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0)
    
    private var underlineLayer: CALayer = CALayer()
    
    // MARK: ErrorLabel
    private var errorLabel: UILabel? = nil
    
    @IBInspectable var error: String = "" {
        didSet {
            if errorLabel == nil && error != "" {
                showError(error: error, animated: true)
            } else {
                hideError(animated: true)
            }
        }
    }
    
    private var errorIsAnimating: Bool = false
    private var errorColor: UIColor = UIColor(red: 255/255, green: 59/255, blue: 49/255, alpha: 1.0)
    private var errorPadding: CGSize = CGSize(width: 0, height: 4)
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        sharedInit()
    }
    
    private func sharedInit() {
        setupView()
        setupTextView()
        setupUnderline()
    }
    
    private func setupView() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onTakeFocus), name: UITextView.textDidBeginEditingNotification, object: textView)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onLostFocus), name: UITextView.textDidEndEditingNotification, object: textView)
    }
    
    override var bounds: CGRect { // frames don't work
        didSet {
            let errorLabelSpace = errorLabel != nil ? errorLabel!.frame.size.height + errorPadding.height : 0
            
            if let placeholderLabel = placeholderLabel {
                textView.frame.size.height = frame.height - placeholderLabel.frame.height - underlineHeight - errorLabelSpace
                if textView.isScrollEnabled {
                    textView.frame.size.height -= textViewInsets.minY + textViewInsets.height
                }
            } else {
                textView.frame.size.height = frame.height - errorLabelSpace
            }
            
            textView.frame.size.width = frame.width
            
            underlineLayer.frame.origin.y = frame.height - underlineHeight - errorLabelSpace
            underlineLayer.frame.size.width = frame.width
        }
    }
    
    private func setupTextView() {
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.keyboardAppearance = .dark
        textView.returnKeyType = .next
        textView.textContainer.lineFragmentPadding = 0
        textView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        addSubview(textView)
        layoutIfNeeded()
    }
    
    private func setupPlaceholder(placeholder: String) {
        placeholderLabel = UILabel()
        placeholderLabel!.textColor = placeholderColor
        placeholderLabel!.text = placeholder
        placeholderLabel!.textAlignment = textAlignment

        if textView.font != nil {
            placeholderLabel!.font = textView.font
        }
        
        let placeholderLabelHeight = placeholderLabel!.requiredHeight
        
        placeholderLabel!.frame = CGRect(
            x: textViewInsets.minX, y: placeholderLabelHeight + textViewInsets.minY,
            width: frame.width - textViewInsets.minX - textViewInsets.width, height: placeholderLabelHeight
        )
        
        if textView.isScrollEnabled {
            frame.size.height += placeholderLabelHeight + textViewInsets.minY
            placeholderLabel!.frame.origin.y += textViewInsets.minY
            textView.frame.origin.y += placeholderLabel!.frame.height + textViewInsets.minY
        } else {
            frame.size.height += placeholderLabelHeight
            textView.frame.origin.y += placeholderLabel!.frame.height
        }
        
        underlineLayer.frame.origin.y = frame.height - underlineHeight
        
        addSubview(placeholderLabel!)
        layoutIfNeeded()
    }
    
    private func setupUnderline() {
        frame.size.height += textView.isScrollEnabled ? underlineHeight + textViewInsets.height : underlineHeight
        
        underlineLayer.backgroundColor = underlineColor.cgColor
        
        underlineLayer.frame = CGRect(x: 0, y: frame.height - underlineHeight, width: frame.width, height: underlineHeight)
        
        layer.addSublayer(underlineLayer)
        layoutIfNeeded()
    }

    private func animatePlaceholderToTop(animated: Bool) {
        if placeholderIsAnimating {
            return
        }
        
        if animated && !placeholderIsAnimating {
            placeholderIsAnimating = true
            
            UIView.animate(
                withDuration: animationDuration,
                delay: 0.0,
                options: .curveEaseOut,
                animations: {
                    self.placeholderLabel!.font = UIFont(name: self.placeholderFontName, size: self.placeholderFontSize)
                    self.placeholderLabel!.frame.origin.y = 0
                    self.layoutIfNeeded()
                },
                completion: { finished in
                    self.placeholderIsAnimating = false
                    // Layout label without animation if state has changed since animation started.
                    if !self.shouldAnimateToTop {
                        self.animatePlaceholderToBottom(animated: false)
                    }
                }
            )
        } else if !animated {
            placeholderLabel?.frame.origin.y = 0
        }
    }

    private func animatePlaceholderToBottom(animated: Bool) {
        if placeholderIsAnimating {
            return
        }
        
        let bottomPosition = textView.isScrollEnabled ?
            placeholderLabel!.frame.height + textViewInsets.minY * 2 :
            placeholderLabel!.frame.height + textViewInsets.minY

        if animated && !placeholderIsAnimating {
            placeholderIsAnimating = true

            UIView.animate(
                withDuration: animationDuration * 0.3,
                delay: 0.0,
                options: .curveEaseOut,
                animations: {
                    self.placeholderLabel!.font = self.textView.font
                    self.placeholderLabel!.frame.origin.y = bottomPosition
                    self.layoutIfNeeded()
                },
                completion: { isFinished in
                    self.placeholderIsAnimating = false
                    // Layout label without animation if state has changed since animation started.
                    if self.shouldAnimateToTop {
                        self.animatePlaceholderToTop(animated: false)
                    }
                }
            )
        } else if !animated {
            placeholderLabel?.frame.origin.y = bottomPosition
        }
    }

    private func updateTextViewFontName(name: String) {
        if textView.font != nil {
            textView.font = UIFont(name: name, size: textViewFontSize)
        } else {
            textView.font = UIFont(name: name, size: 16.0)
        }
        
        if let placeholderLabel = placeholderLabel {
            placeholderLabel.font = textView.font
        }
    }
    
    private func updateTextViewFontSize(size: CGFloat) {
        if textView.font != nil {
            textView.font = textView.font?.withSize(size)
        } else {
            textView.font = UIFont.systemFont(ofSize: size)
        }
        
        if let placeholderLabel = placeholderLabel {
            placeholderLabel.font = textView.font
        }
    }
    
    private func updatePlaceholderText(text: String) {
        if let placeholderLabel = placeholderLabel {
            placeholderLabel.text = text
        } else {
            setupPlaceholder(placeholder: text)
        }
    }
    
    private func showError(error: String, animated: Bool) {
        if errorIsAnimating {
            return
        }
        
        errorLabel = UILabel()
        errorLabel!.textColor = errorColor
        errorLabel!.text = error
        errorLabel!.font = UIFont(name: labelFontName, size: labelFontSize)
        errorLabel!.textAlignment = textAlignment
        errorLabel!.alpha = 0.0
        
        let errorLabelHeight = errorLabel!.requiredHeight
        
        errorLabel!.frame = CGRect(
            x: errorPadding.width,
            y: frame.height - errorLabelHeight,
            width: frame.width - errorPadding.width * 2 - textViewInsets.minX - textViewInsets.width,
            height: errorLabelHeight
        )
        
        addSubview(errorLabel!)
        layoutIfNeeded()
        
        let bottomPosition = errorLabelHeight + errorPadding.height
        
        if animated && !errorIsAnimating {
            errorIsAnimating = true
            
            UIView.animate(
                withDuration: animationDuration,
                delay: 0.0,
                options: .curveEaseOut,
                animations: {
                    self.errorLabel!.frame.origin.y += bottomPosition
                    self.errorLabel!.alpha = 1.0
                    
                    self.frame.size.height += bottomPosition
                    
                    if self.placeholderLabel != nil {
                        self.placeholderLabel!.textColor = self.errorColor
                    }
                    self.underlineLayer.backgroundColor = self.errorColor.cgColor
                    
                    self.layoutIfNeeded()
                },
                completion: { isFinished in
                    self.errorIsAnimating = false
                    // Layout label without animation if state has changed since animation started.
                    if self.error == "" {
                        self.hideError(animated: false)
                    }
                }
            )
        } else if !animated {
            errorLabel?.frame.origin.y += bottomPosition
            self.frame.size.height += bottomPosition
        }
    }
    
    private func hideError(animated: Bool) {
        if errorIsAnimating || errorLabel == nil {
            return
        }
        
        let topPosition = errorLabel!.frame.height + errorPadding.height
        
        if animated && !errorIsAnimating {
            
            errorIsAnimating = true
            
            UIView.animate(
                withDuration: animationDuration * 0.5,
                delay: 0.0,
                options: .curveEaseInOut,
                animations: {
                    self.errorLabel!.frame.origin.y -= topPosition
                    self.errorLabel!.alpha = 0.0
                    
                    self.frame.size.height -= topPosition
                    
                    if self.placeholderLabel != nil {
                        self.placeholderLabel!.textColor = self.tintColor
                    }
                    self.underlineLayer.backgroundColor = self.tintColor.cgColor
                    
                    self.layoutIfNeeded()
                },
                completion: { isFinished in
                    self.errorIsAnimating = false
                    self.errorLabel!.removeFromSuperview()
                    self.errorLabel = nil
                    // Layout label without animation if state has changed since animation started.
                    if self.error != "" {
                        self.showError(error: self.error, animated: false)
                    }
                }
            )
        } else if !animated {
            errorLabel!.removeFromSuperview()
            errorLabel = nil
            self.frame.size.height -= topPosition
        }
    }
    
    @objc
    private func onTakeFocus() {
        placeholderLabel!.textColor = errorLabel != nil ? errorColor : tintColor
        animatePlaceholderToTop(animated: true)
        
        underlineLayer.frame.size.height = underlineEditingHeight
        if errorLabel == nil {
            underlineLayer.backgroundColor = tintColor.cgColor
        }
    }
    
    @objc
    private func onLostFocus() {
        if textView.text == "" {
            animatePlaceholderToBottom(animated: true)
        }
        
        underlineLayer.frame.size.height = underlineHeight
        if errorLabel == nil {
            placeholderLabel!.textColor = placeholderColor
            underlineLayer.backgroundColor = underlineColor.cgColor
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension UILabel{
    
    public var requiredHeight: CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }
}
