//
//  ExtensionViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class ExtensionViewController: UIViewController {
    var context: ExtensionContext!
    
    var subTitle: String? = nil
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
