//
//  RouterNavigationController.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

@IBDesignable
class RouterNavigationController: UINavigationController, RouterViewProtocol {
    
    @IBInspectable
    var backgroundColor: UIColor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = backgroundColor
        
        for controller in viewControllers {
            if let ctrl = controller as? RouterViewProtocol {
                ctrl.r_inject(context: r_context, resolver: r_resolver)
            }
            if let ctrl = controller as? ContextSubject {
                ctrl.apply(context: r_context)
            }
        }
    }
}
