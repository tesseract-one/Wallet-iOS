//
//  UITextView+Bond.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/13/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
import ReactiveKit

public enum UITextViewReactiveExtensionsNotificationType {
    case textDidBeginEditing
    case textDidChange
    case textDidEndEditing
    
    var notification: NSNotification.Name {
        switch self {
        case .textDidChange:
            return UITextView.textDidChangeNotification
        case .textDidEndEditing:
            return UITextView.textDidEndEditingNotification
        case .textDidBeginEditing:
            return UITextView.textDidBeginEditingNotification
        }
    }
}

public extension ReactiveExtensions where Base: UITextView {
    public func notification(_ type: UITextViewReactiveExtensionsNotificationType) -> SafeSignal<UITextView> {
        let base = self.base
        return Signal { [weak base] observer in
            guard let base = base else {
                observer.completed()
                return NonDisposable.instance
            }
            let target = BNDTextViewTarget(view: base, notification: type) {
                observer.next($0)
            }
            return BlockDisposable {
                target.unregister()
            }
        }.take(until: base.deallocated)
    }
}

@objc fileprivate class BNDTextViewTarget: NSObject
{
    private let observer: (UITextView) -> Void
    
    fileprivate init(view: UITextView, notification: UITextViewReactiveExtensionsNotificationType, observer: @escaping (UITextView) -> Void) {
        self.observer = observer
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(actionHandler), name: notification.notification, object: view)
    }
    
    @objc private func actionHandler(notification: NSNotification) {
        observer(notification.object as! UITextView)
    }
    
    fileprivate func unregister() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        unregister()
    }
}

#endif
