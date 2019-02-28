//
//  Views.swift
//  Rubric
//
//  Created by Daniel Leping on 11/02/2017.
//  Copyright © 2017 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import UIKit

private let _r_context_key = unsafeBitCast(Selector(("_r_context_key")), to: UnsafeRawPointer.self)
private let _r_resolver_key = unsafeBitCast(Selector(("_r_resolver_key")), to: UnsafeRawPointer.self)

enum ViewId {
    case root
    case named(name:String)
}

enum ViewError : Error {
    case notFound(view: ViewId)
}


extension RouterView where Self: NSObject {
    var r_context: RouterContextProtocol {
        return objc_getAssociatedObject(self, _r_context_key)! as! RouterContextProtocol
    }
    
    var r_resolver: ViewResolverProtocol {
        return objc_getAssociatedObject(self, _r_resolver_key)! as! ViewResolverProtocol
    }
    
    func r_inject(context: RouterContextProtocol, resolver: ViewResolverProtocol) {
        objc_setAssociatedObject(self, _r_context_key, context, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, _r_resolver_key, resolver, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

protocol ViewFactoryProtocol {
    func viewController(for view: ViewId, context:RouterContextProtocol?) throws -> UIViewController
}

extension ViewFactoryProtocol {
    func viewController(for view: ViewId) throws -> UIViewController {
        return try viewController(for: view, context: nil)
    }
    
    func viewController(context:RouterContextProtocol?) throws -> UIViewController {
        return try viewController(for: .root, context: context)
    }
    
    func viewController() throws -> UIViewController {
        return try viewController(for: .root, context: nil)
    }
}

protocol RouterView: ViewFactoryProtocol {
    var r_context: RouterContextProtocol { get }
    var r_resolver: ViewResolverProtocol { get }
    
    func r_inject(context: RouterContextProtocol, resolver: ViewResolverProtocol)
}

extension RouterView {
    func viewController(for view: ViewId, context: RouterContextProtocol?) throws -> UIViewController {
        let vf = ViewFactory(resolver: r_resolver, context: r_context)
        return try vf.viewController(for: view, context: context)
    }
}

protocol ViewResolverProtocol {
    func instantiate(for view: ViewId) -> UIViewController?
}

class CompoundViewResolver : ViewResolverProtocol {
    private let _this:ViewResolverProtocol
    private let _next:ViewResolverProtocol?
    
    init(this:ViewResolverProtocol, next:ViewResolverProtocol? = nil) {
        _this = this
        _next = next
    }
    
    func instantiate(for view: ViewId) -> UIViewController? {
        return _this.instantiate(for: view) ?? _next?.instantiate(for: view)
    }
}

extension ViewResolverProtocol {
    func appending(resolver:ViewResolverProtocol) -> ViewResolverProtocol {
        return CompoundViewResolver(this: self, next: resolver)
    }
    
    func prepending(resolver:ViewResolverProtocol) -> ViewResolverProtocol {
        return CompoundViewResolver(this: resolver, next: self)
    }
}

extension UIStoryboard : ViewResolverProtocol {
    func instantiate(for view: ViewId) -> UIViewController? {
        switch view {
        case .root:
            return instantiateInitialViewController()
        case .named(let name):
            return instantiateViewController(withIdentifier: name)
        }
    }
}

class SingleViewResolver<Controller : UIViewController> : ViewResolverProtocol {
    private let _name:String
    private let _factory:()->Controller
    
    init(name:String, factory:@escaping ()->Controller) {
        _name = name
        _factory = factory
    }
    
    func instantiate(for view: ViewId) -> UIViewController? {
        guard case let .named(name) = view, name == _name else {
            return nil
        }
        
        return _factory()
    }
}

class ViewFactory : ViewFactoryProtocol {
    private let _resolver:ViewResolverProtocol
    private let _context:RouterContextProtocol?
    
    init(resolver:ViewResolverProtocol, context:RouterContextProtocol? = nil) {
        _resolver = resolver
        _context = context
    }
    
    func viewController(for view: ViewId, context:RouterContextProtocol?) throws -> UIViewController {
        guard let controller = _resolver.instantiate(for: view) else {
            throw ViewError.notFound(view: view)
        }
        
        let ctx = CombinedRouterContext()
        
        if let co = _context {
            ctx.push(context: co)
        }
        
        if let co = context {
            ctx.push(context: co)
        }
        
        if let rvw = controller as? RouterView {
            rvw.r_inject(context: ctx, resolver: _resolver)
        }
        
        if let cs = controller as? ContextSubject {
            cs.apply(context: ctx)
        }
        
        return controller
    }
}

class WeakContextViewFactory: ViewFactory {
    private weak var _context: (RouterContextProtocol & AnyObject)?
}

extension ViewFactoryProtocol {
    func viewController(for view: ViewId = .root, context:DictionaryRouterContext) throws -> UIViewController {
        let ctx:RouterContextProtocol = context
        return try viewController(for: view, context: ctx)
    }
}
