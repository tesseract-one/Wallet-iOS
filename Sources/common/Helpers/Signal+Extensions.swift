//
//  Signal+Extensions.swift
//  Tesseract
//
//  Created by Yura Kulynych on 2/27/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit

extension SignalProtocol {
    func with<T:AnyObject>(weak: T) -> Signal<(Element, T), Error> {
        weak var w = weak
        return Signal { observer in
            return self.observe { event in
                switch event {
                case .next(let element):
                    if let w = w {
                        observer.next((element, w))
                    }
                case .completed:
                    observer.completed()
                case .failed(let err):
                    observer.failed(err)
                }
            }
        }
    }
    
    func with<T1:AnyObject, T2: AnyObject>(weak t1: T1, _ t2: T2) -> Signal<(Element, T1, T2), Error> {
        weak var wt1 = t1
        weak var wt2 = t2
        return Signal { observer in
            return self.observe { event in
                switch event {
                case .next(let element):
                    if let t1 = wt1, let t2 = wt2 {
                        observer.next((element, t1, t2))
                    }
                case .completed:
                    observer.completed()
                case .failed(let err):
                    observer.failed(err)
                }
            }
        }
    }
    
    
    func with<T1:AnyObject, T2: AnyObject, T3: AnyObject>(weak t1: T1, _ t2: T2, _ t3: T3) -> Signal<(Element, T1, T2, T3), Error> {
        weak var wt1 = t1
        weak var wt2 = t2
        weak var wt3 = t3
        return Signal { observer in
            return self.observe { event in
                switch event {
                case .next(let element):
                    if let t1 = wt1, let t2 = wt2, let t3 = wt3 {
                        observer.next((element, t1, t2, t3))
                    }
                case .completed:
                    observer.completed()
                case .failed(let err):
                    observer.failed(err)
                }
            }
        }
    }
}

extension SignalProtocol where Element == Void {
    func with<T:AnyObject>(weak: T) -> Signal<T, Error> {
        weak var w = weak
        return Signal { observer in
            return self.observe { event in
                switch event {
                case .next(_):
                    if let w = w {
                        observer.next(w)
                    }
                case .completed:
                    observer.completed()
                case .failed(let err):
                    observer.failed(err)
                }
            }
        }
    }
    
    func with<T1:AnyObject, T2: AnyObject>(weak t1: T1, _ t2: T2) -> Signal<(T1, T2), Error> {
        weak var wt1 = t1
        weak var wt2 = t2
        return Signal { observer in
            return self.observe { event in
                switch event {
                case .next(_):
                    if let t1 = wt1, let t2 = wt2 {
                        observer.next((t1, t2))
                    }
                case .completed:
                    observer.completed()
                case .failed(let err):
                    observer.failed(err)
                }
            }
        }
    }
}

extension _ResultProtocol {
    var error: Error? {
        switch _unbox {
        case .failure(let err): return err
        default: return nil
        }
    }
    
    var value: Value? {
        switch _unbox {
        case .success(let val): return val
        default: return nil
        }
    }
}

extension SignalProtocol {
    func resultMap<U>(_ transform: @escaping (Element) throws -> U) -> Signal<Swift.Result<U, Swift.Error>, Error> {
        return map { val -> Swift.Result<U, Swift.Error> in
            do {
                return try .success(transform(val))
            } catch let err {
                return .failure(err)
            }
        }
    }
}

extension SignalProtocol where Self.Element: _ResultProtocol {
    var errorNode: Signal<Element.Error, Error> {
        return filter{$0.error != nil}.map{$0.error!}
    }
    
    var suppressedErrors: Signal<Element.Value, Error> {
        return filter{$0.value != nil}.map{$0.value!}
    }
    
    func pourError<S>(into listener: S) -> Signal<Element.Value, Error> where S: SubjectProtocol, S.Element == Element.Error {
        return doOn(next: { e in if e.error != nil { listener.next(e.error!) } }).suppressedErrors
    }
    
    func tryMapWrapped<U>(_ transform: @escaping (Element.Value) throws -> U) -> Signal<Swift.Result<U, Element.Error>, Error> {
        return map { result in
            if let err = result.error {
                return .failure(err)
            }
            do {
                return try .success(transform(result.value!))
            } catch let err as Element.Error {
                return .failure(err)
            } catch let err {
                fatalError("Unknown error \(err)")
            }
        }
    }
    
    func mapWrapped<U>(_ transform: @escaping (Element.Value) -> U) -> Signal<Swift.Result<U, Element.Error>, Error> {
        return map { res in
            if let val = res.value {
                return .success(transform(val))
            }
            return .failure(res.error!)
        }
    }
    
    func mapWrappedError<E: Swift.Error>(_ transform: @escaping (Element.Error) -> E) -> Signal<Swift.Result<Element.Value, E>, Error> {
        return map { res in
            if let err = res.error {
                return .failure(transform(err))
            }
            return .success(res.value!)
        }
    }
    
    func flatMap<O: SignalProtocol>(_ strategy: FlattenStrategy, _ transform: @escaping (Element.Value) -> O) -> Signal<Result<O.Element.Value, O.Element.Error>, O.Error> where O.Element: _ResultProtocol, O.Error == Error, O.Element.Error == Element.Error {
        return map { (res) -> Signal<Result<O.Element.Value, O.Element.Error>, O.Error> in
            if let val = res.value {
                return transform(val).mapWrapped{$0}
            }
            return Signal(just: Result<O.Element.Value, O.Element.Error>.failure(res.error!))
        }.flatten(strategy)
    }
    
    func flatMapLatest<O: SignalProtocol>(_ transform: @escaping (Element.Value) -> O) -> Signal<Result<O.Element.Value, O.Element.Error>, O.Error> where O.Element: _ResultProtocol, O.Error == Error, O.Element.Error == Element.Error {
        return flatMap(.latest, transform)
    }
    
    func flatMapMerge<O: SignalProtocol>(_ transform: @escaping (Element.Value) -> O) -> Signal<Result<O.Element.Value, O.Element.Error>, O.Error> where O.Element: _ResultProtocol, O.Error == Error, O.Element.Error == Element.Error {
        return flatMap(.merge, transform)
    }
    
    func flatMapConcat<O: SignalProtocol>(_ transform: @escaping (Element.Value) -> O) -> Signal<Result<O.Element.Value, O.Element.Error>, O.Error> where O.Element: _ResultProtocol, O.Error == Error, O.Element.Error == Element.Error {
        return flatMap(.latest, transform)
    }
}

public typealias ResultSignal<T, E: Error> = SafeSignal<Swift.Result<T, E>>

extension ResultSignal {
    public static func success<T, E: Swift.Error>(_ value: T) -> ResultSignal<T, E> {
        return ResultSignal(just: .success(value))
    }
    
    public static func failure<T, E: Swift.Error>(_ error: E) -> ResultSignal<T, E> {
        return ResultSignal(just: .failure(error))
    }
}
