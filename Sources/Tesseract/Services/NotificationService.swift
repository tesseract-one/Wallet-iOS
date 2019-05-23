//
//  NortificationService.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/9/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit
import Bond
import SnapKit


enum NotificationType {
    case error
    case warning
    case message
}

protocol NotificationProtocol {
    var title: String { get }
    var description: String? { get }
    var emoji: String { get }
    var lifetime: TimeInterval { get }
}

protocol TypedNotificationProtocol: NotificationProtocol {
    var type: NotificationType { get }
}

extension TypedNotificationProtocol {
    var emoji: String {
        switch type {
        case .error: return "🙄"
        case .warning: return "🤔"
        case .message: return "🤗"
        }
    }
}

struct NotificationInfo: TypedNotificationProtocol {
    public let title: String
    public let description: String?
    public let type: NotificationType
    public let lifetime: TimeInterval
    
    init(title: String, description: String? = nil, type: NotificationType = .message, lifetime: TimeInterval = 3.0) {
        self.title = title
        self.description = description
        self.type = type
        self.lifetime = lifetime
    }
}

class NotificationService {
    private let bag = DisposeBag()
    
    private var notifications = [NotificationProtocol]()
    private let queue = DispatchQueue.main
    
    private var notificationView: NotificationView!
    private var topConstraint: Constraint? = nil
    
    public var rootContainer: ViewControllerContainer!
    
    public var notificationNode: SafePublishSubject<NotificationProtocol>!
    
    public var animationDuration: TimeInterval = 0.3
    
    func bootstrap() {
        notificationView = NotificationView.create()
        notificationNode.with(weak: self)
            .observeNext { notification, sself in
                sself.showNotification(notification)
            }.dispose(in: bag)
    }
    
    public func showNotification(_ notification: NotificationProtocol) {
        queue.async {
            self.notifications.append(notification)
            self.show()
        }
    }
    
    public func showNotification(title: String, description: String? = nil, type: NotificationType = .message, lifetime: TimeInterval = 3.0) {
        showNotification(NotificationInfo(title: title, description: description, type: type, lifetime: lifetime))
    }
    
    private func showUI(notification: NotificationProtocol) {
        let rootView = rootContainer.windowView
        
        DispatchQueue.main.async {
            self.notificationView.setNotification(notification)
            
            rootView.addSubview(self.notificationView)
            self.notificationView.alpha = 0
            self.notificationView.snp.makeConstraints { make in
                make.leading.equalTo(rootView.safeAreaLayoutGuide.snp.leading).offset(16)
                make.trailing.equalTo(rootView.safeAreaLayoutGuide.snp.trailing).offset(-16)
                self.topConstraint = make.top.equalTo(rootView.safeAreaLayoutGuide.snp.top).offset(0).constraint
            }
            
            rootView.layoutSubviews()
            self.topConstraint?.update(offset: -self.notificationView.frame.height)
            rootView.layoutSubviews()
            let topOffset = UIScreen.main.bounds.width > 320 ? 24 : 0
            self.topConstraint?.update(offset: topOffset)
            
            UIView.animate(withDuration: self.animationDuration, delay: 0.0, options: .curveEaseInOut, animations: {
                self.notificationView.alpha = 1
                rootView.layoutSubviews()
            }) { _ in
                self.queue.asyncAfter(deadline: .now() + .milliseconds(Int(notification.lifetime * 1000))) {
                    self.hide()
                }
            }
        }
    }
    
    private func hideUI(endCb: @escaping () -> Void) {
        let rootView = rootContainer.windowView
        
        DispatchQueue.main.async {
            rootView.layoutSubviews()
            self.topConstraint?.update(offset: -self.notificationView.frame.height)
            UIView.animate(withDuration: self.animationDuration, delay: 0.0, options: .curveEaseInOut, animations: {
                self.notificationView.alpha = 0
                rootView.layoutSubviews()
            }) { _ in
                self.notificationView.removeFromSuperview()
                self.topConstraint = nil
                endCb()
            }
        }
    }
    
    // Should be called only in internal queue
    private func show() {
        guard self.notifications.count == 1 else { return }
        self.showUI(notification: self.notifications[0])
    }
    
    private func hide() {
        hideUI {
            self.queue.async {
                self.notifications.remove(at: 0)
                if self.notifications.count > 0 {
                    self.showUI(notification: self.notifications[0])
                }
            }
        }
    }
}
