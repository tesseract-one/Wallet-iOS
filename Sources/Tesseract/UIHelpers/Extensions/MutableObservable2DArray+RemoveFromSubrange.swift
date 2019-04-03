//
//  MutableObservable2DArray+RemoveFromSubrange.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/3/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Bond
import ReactiveKit

extension Property where Value: TreeChangesetProtocol, Value.Collection: Array2DProtocol {
    
    func removeFromSubrange<R: RangeExpression>(section: Int, range: R) where R.Bound == Value.Collection.Children.Index {
        let fixed = range.relative(to: self[sectionAt: section].items)
        for _ in fixed {
            removeItem(at: IndexPath(row: fixed.lowerBound, section: section))
        }
    }
    
    func removeFromSubrange(section: Int, range: UnboundedRange) {
        let count = self[sectionAt: section].items.count
        for _ in 0..<count {
            removeItem(at: IndexPath(row: 0, section: section))
        }
    }
}
