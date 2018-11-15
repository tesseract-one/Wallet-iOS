//
//  TermsOfServiceViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/15/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class TermsOfServiceViewController: UIViewController {
  
  // MARK: Outlets
  @IBOutlet weak var termsTextView: UITextView!
  
  // MARK: Lifecycle hooks
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
  }
  
  override func viewDidLayoutSubviews() {
    termsTextView.setContentOffset(.zero, animated: false)
  }
  
  // MARK: Default values
  //
  // Make the Status Bar Light/Dark Content for this View
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
  
  // MARK: Actions
  //
  @IBAction func agreeWithTerms(_ sender: UIButton) {
    print("Agree with Terms of Service")
  }

  
  // MARK: Private functions
  //
  private func setUp() {
    // Set up TextView
    termsTextView.text = "When someone does something that they know that they shouldn’t do, did they really have a choice. Maybe what I mean to say is did they really have a chance. You can take two people, present them with the same fork in the road, and one is going to have an easier time than the other choosing the right path.\nIs there such a thing as the right path? You could argue back and forth with God and Evolution and such topics. The side that you take in an arguement like that might lead you to think that you know the meaning to life. How can we really know though. At least up until now there isn’t and 100% proof to either side. If God was a gaurantee – why would he leave so many of us here to die, without the information or say it as proof that we individually would have needed to make that choice?"
    termsTextView.textContainerInset = UIEdgeInsets.init(top: 15, left: 0, bottom: 25, right: 0)
    termsTextView.showsVerticalScrollIndicator = true
  }
}
