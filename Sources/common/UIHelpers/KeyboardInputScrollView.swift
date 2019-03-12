//
//  KeyboardInputScrollView.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/13/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

@IBDesignable
class KeyboardInputScrollViewControlContainer: UIView {
    @IBInspectable
    public var visiblePart: CGFloat = -1.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if visiblePart < 0 {
            visiblePart = self.frame.height
        }
    }
}

extension UIView {
    fileprivate var container: KeyboardInputScrollViewControlContainer? {
        if let cont = self as? KeyboardInputScrollViewControlContainer {
            return cont
        }
        return superview?.container
    }
}


class KeyboardInputScrollView: UIScrollView {
    private var containers: Array<KeyboardInputScrollViewControlContainer> = []
    private var activeContainer: KeyboardInputScrollViewControlContainer? = nil
    
    public weak var navigationBar: UINavigationBar?
    
    private func attachToNotifications(view: UIView) {
        switch view {
        case let view as UITextField:
            NotificationCenter.default.addObserver(self, selector: #selector(self.beginEditing), name: UITextField.textDidBeginEditingNotification, object: view)
        case let view as UITextView:
            NotificationCenter.default.addObserver(self, selector: #selector(self.beginEditing), name: UITextView.textDidBeginEditingNotification, object: view)
        default:
            for subview in view.subviews {
                attachToNotifications(view: subview)
            }
        }
    }
    
    private func scanForContainers(in view: UIView) -> Array<KeyboardInputScrollViewControlContainer> {
        var containers: Array<KeyboardInputScrollViewControlContainer> = []
        for subview in view.subviews {
            if let container = subview as? KeyboardInputScrollViewControlContainer {
                containers.append(container)
                attachToNotifications(view: container)
            } else {
                containers.append(contentsOf: scanForContainers(in: subview))
            }
        }
        return containers
    }
    
    @objc private func beginEditing(notification: Notification) {
        let view = notification.object! as! UIView
        activeContainer = view.container
        scrollToContainer(container: view.container!)
    }
    
    private func scrollToContainer(container: KeyboardInputScrollViewControlContainer) {
        let index = containers.firstIndex(of: container)!
        let next = index < containers.count-1 ? containers[index+1] : nil
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if self.contentInset.bottom < 0.0001 { // It can be called before inset update
                return
            }
            
            let largeBarConstant = self.navigationBar != nil ? self.navigationBar!.bounds.height - 44.0 : 0.0 // Magic number!!!
            
            let topY = self.contentOffset.y
            let bottomY = topY + (self.bounds.height - self.contentInset.bottom) + largeBarConstant // topY + visible height
            
            let cTopY = self.convert(.zero, from: container).y
            let cBottomY = self.convert(CGPoint(x: 0, y: container.frame.height), from: container).y
            
            if cTopY >= topY && cBottomY <= bottomY {
                if let next = next {
//                    let nTopY = self.convert(.zero, from: next).y
                    let nBottomY = self.convert(CGPoint(x: 0, y: min(next.frame.height, next.visiblePart)), from: next).y
                    
                    if nBottomY > bottomY && (cTopY - (nBottomY - bottomY)) >= topY {
                        self.setContentOffset(CGPoint(x: 0, y: topY + (nBottomY - bottomY)), animated: true)
                    }
                }
            } else {
                var newY = cTopY
                
                if cBottomY > bottomY && (cBottomY - cTopY) < (bottomY - topY) {
                    if let next = next {
                        let nBottomY = self.convert(CGPoint(x: 0, y: min(next.frame.height, next.visiblePart)), from: next).y
                        
                        if nBottomY > bottomY && (cTopY - (nBottomY - bottomY)) >= topY {
                           newY = topY + (nBottomY - bottomY)
                        }
                    }
                }
                
                self.setContentOffset(CGPoint(x: 0, y: newY), animated: true)
            }
        }
    }
    
    @objc private func onKeyboardOpened(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            contentInset = contentInsets
            scrollIndicatorInsets = contentInsets
            
            if let container = activeContainer, contentInsets.bottom > 0.0001 {
                scrollToContainer(container: container)
            }
        }
    }
    
    @objc private func onKeyboardClosed(notification: NSNotification) {
        contentInset = .zero
        scrollIndicatorInsets = .zero
        
        setContentOffset(CGPoint(x: contentOffset.x, y: -contentInset.top), animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containers = scanForContainers(in: self)
        
        containers.sort { left, right in
            let leftPos = self.convert(CGPoint.zero, from: left)
            let rightPos = self.convert(CGPoint.zero, from: right)
            return leftPos.y < rightPos.y
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardOpened), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardClosed), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
