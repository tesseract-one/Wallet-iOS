//
//  RegistrationRootViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit


class RegistrationRootViewController: UINavigationController, RouterViewProtocol {
  
    override func viewDidLoad() {
      super.viewDidLoad()
      let vc = try! viewController(for: .named(name: "SignUp"), context: nil)
      pushViewController(vc, animated: false)
    }
  
}
