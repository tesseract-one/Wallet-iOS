//
//  KeyboardAutoScrollView.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/13/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit

@IBDesignable
class KeyboardAutoScrollContainer: UIView {
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
    fileprivate var container: KeyboardAutoScrollContainer? {
        if let cont = self as? KeyboardAutoScrollContainer {
            return cont
        }
        return superview?.container
    }
}



class KeyboardAutoScrollViewController: UIViewController {

    private var isLargeTitle: Bool = false
    
    @IBOutlet weak var scrollView: KeyboardAutoScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardOpened), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardClosed), name: UIResponder.keyboardWillHideNotification, object: nil)
    
        self.isLargeTitle = navigationController?.navigationBar != nil ? navigationController!.navigationBar.bounds.height > CGFloat(60.0) : false
        
        if isLargeTitle {
            breakLargeTitleDefaultBehaviour()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = self.isLargeTitle
    }
    
    @objc private func onKeyboardOpened(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            scrollView.addKeyboardInsets(keyboardFrame: keyboardFrame)
        }
        
        if isLargeTitle {
            hideLargeTitle {
                self.scrollView.scrollToActive(headerHeight: $0)
            }
        } else {
            self.scrollView.scrollToActive()
        }
    }
    
    @objc private func onKeyboardClosed(notification: NSNotification) {
       scrollView.removeKeyboardInsets()
        
        if isLargeTitle {
            showLargeTitle {
                self.scrollView.scrollToTop()
            }
        } else {
            self.scrollView.scrollToTop()
        }
    }
    
    public func hideLargeTitle(scrollTo: @escaping (CGFloat?) -> Void) {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.layoutIfNeeded()
 
        DispatchQueue.main.after(when: 0.0) {
            scrollTo(nil)
        }
    }
    
    public func showLargeTitle(scrollTo: @escaping () -> Void) {
        UIView.animate(withDuration: 1.0,
                       animations: {
                        self.navigationController?.navigationBar.prefersLargeTitles = true
                        self.navigationController?.navigationBar.layoutIfNeeded()
                       },
                       completion: { _ in scrollTo() }
        )
    }
    
    private func breakLargeTitleDefaultBehaviour() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        scrollView.superview?.addSubview(view)
        scrollView.superview?.sendSubviewToBack(view)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



class KeyboardAutoScrollView: UIScrollView {
    private var containers: Array<KeyboardAutoScrollContainer> = []
    private var activeContainer: KeyboardAutoScrollContainer? = nil
    
    public var isScrollingEnabled: Bool = false
    
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
    
    private func scanForContainers(in view: UIView) -> Array<KeyboardAutoScrollContainer> {
        var containers: Array<KeyboardAutoScrollContainer> = []
        for subview in view.subviews {
            if let container = subview as? KeyboardAutoScrollContainer {
                containers.append(container)
                attachToNotifications(view: container)
            } else {
                containers.append(contentsOf: scanForContainers(in: subview))
            }
        }
        return containers
    }
    
    public func scrollToActive(headerHeight: CGFloat? = nil) {
        isScrollingEnabled = true
        
        if let container = activeContainer {
            scrollToContainer(container: container, headerHeight: headerHeight)
        }
    }
    
    public func scrollToTop() {
        isScrollingEnabled = false
        setContentOffset(CGPoint(x: contentOffset.x, y: -contentInset.top), animated: true)
    }
    
    private func scrollToContainer(container: KeyboardAutoScrollContainer, headerHeight: CGFloat? = nil) {
        let index = containers.firstIndex(of: container)!
        let next = index < containers.count-1 ? containers[index+1] : nil
            
        let topY = self.contentOffset.y
        let bottomY = topY + (self.bounds.height - self.contentInset.bottom) + (headerHeight ?? 0.0)
        
        let cTopY = self.convert(.zero, from: container).y
        let cBottomY = self.convert(CGPoint(x: 0, y: container.frame.height), from: container).y
        
        var newY = topY
        
        if cTopY >= topY && cBottomY <= bottomY {
            if let next = next {
                let nBottomY = self.convert(CGPoint(x: 0, y: min(next.frame.height, next.visiblePart)), from: next).y
                
                if nBottomY > bottomY && (cTopY - (nBottomY - bottomY)) >= topY {
                    newY = topY + (nBottomY - bottomY)
                }
            }
        } else {
            newY = cTopY
            
            if cBottomY > bottomY && (cBottomY - cTopY) < (bottomY - topY) {
                if let next = next {
                    let nBottomY = self.convert(CGPoint(x: 0, y: min(next.frame.height, next.visiblePart)), from: next).y
                    
                    if nBottomY > bottomY && (cTopY - (nBottomY - bottomY)) >= topY {
                        newY = topY + (nBottomY - bottomY)
                    }
                } else {
                    newY = topY + (cBottomY - bottomY)
                }
            }
        }
        
        self.setContentOffset(CGPoint(x: 0, y: newY), animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containers = scanForContainers(in: self)
        
        containers.sort { left, right in
            let leftPos = self.convert(CGPoint.zero, from: left)
            let rightPos = self.convert(CGPoint.zero, from: right)
            return leftPos.y < rightPos.y
        }
    }
    
    @objc private func beginEditing(notification: Notification) {
        let view = notification.object! as! UIView
        activeContainer = view.container
        
        if isScrollingEnabled {
            scrollToContainer(container: view.container!)
        }
    }
    
    public func addKeyboardInsets(keyboardFrame: NSValue) {
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        contentInset = contentInsets
        scrollIndicatorInsets = contentInsets
    }
    
    public func removeKeyboardInsets() {
        contentInset = .zero
        scrollIndicatorInsets = .zero
    }
}
