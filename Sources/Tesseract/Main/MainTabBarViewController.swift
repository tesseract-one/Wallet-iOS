//
//  MainTabBarViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController, RouterViewProtocol {

  override func viewDidLoad() {
    super.viewDidLoad()
    let vc = try! viewController(for: .named(name: "Home"), context: nil)
    setViewControllers([vc], animated: false)
  }
}
