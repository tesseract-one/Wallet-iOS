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
