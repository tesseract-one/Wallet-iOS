//
//  ApplicationContext.swift
//  Rubric
//
//  Created by Daniel Leping on 09/02/2017.
//  Copyright © 2017 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

protocol RouterContextProtocol {
    func get(bean: String) -> Any?
    func get<T>(context: T.Type) -> T?
}

extension RouterContextProtocol {
    func get(bean: String) -> Any? {
        let m = Mirror(reflecting: self)
        return m.descendant(bean)
    }
}

protocol ContextSubject {
    func apply(context: RouterContextProtocol)
}

extension RouterContextProtocol {
    func get<T>(context type: T.Type) -> T? {
        return self as? T
    }
}

class CombinedRouterContext : RouterContextProtocol {
    private var _stack = Array<RouterContextProtocol>()
    
    public func push(context: RouterContextProtocol) {
        _stack.append(context)
    }
    
    public func pop() -> RouterContextProtocol {
        return _stack.removeLast()
    }
    
    func get(bean name: String) -> Any? {
        for layer in _stack.reversed() {
            if let bean = layer.get(bean: name) {
                return bean
            }
        }
        return nil
    }
    
    func get<T>(context type: T.Type) -> T? {
        for layer in _stack.reversed() {
            if let context = layer.get(context: type) {
                return context
            }
        }
        return nil
    }
}

class DictionaryRouterContext : ExpressibleByDictionaryLiteral, RouterContextProtocol {
    typealias Key = String
    typealias Value = Any
    
    private var _ctx = Dictionary<Key, Value>()
    
    public required init(dictionaryLiteral elements: (Key, Value)...) {
        for (k, v) in elements {
            _ctx[k] = v
        }
    }
    
    func get(bean name: String) -> Any? {
        return _ctx[name]
    }
}

extension RouterContextProtocol {
    func concat(_ other: RouterContextProtocol?) -> RouterContextProtocol {
        guard let context = other else { return self }
        let combined = CombinedRouterContext()
        combined.push(context: self)
        combined.push(context: context)
        return combined
    }
}
