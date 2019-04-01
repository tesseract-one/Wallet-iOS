//
//  ViewModelCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class ViewModelCell<Model: ViewModel>: UITableViewCell {
    var model: Model? = nil {
        willSet {
            unadvise()
        }
        didSet {
            advise()
        }
    }
    
    func advise() {}
    
    func unadvise() {
        bag.dispose()
    }
}
