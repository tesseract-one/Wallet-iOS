//
//  RegistrationViewFactory.swift
//  Tesseract
//
//  Created by Yehor Popovych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class RegistrationViewFactory: WeakContextViewFactory {
    var registrationView: UIViewController {
        return try! viewController(for: .named(name: "RegistrationController"))
    }
    
    var unlockView: UIViewController {
        return try! viewController(for: .named(name: "SignInController"))
    }
}
