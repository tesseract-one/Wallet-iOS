//
//  AppState.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/27/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

//TODO: Remove this SHIT

import Foundation

class AppState {
  
  // MARK: Properties
  //
  static let shared = AppState()
  
  struct Wallet {
    var mnemonic: String = ""
    var unblocked: Bool = false {
      didSet {
        if unblocked == true {
          NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UnblockedWallet"), object: self)
        }
      }
    }
    var stub: Stub
  }
  
  var wallet: Wallet?
  
  // MARK: Initialization
  //
  private init() {}

  // MARK: Methods
  //
  func createWallet() {
    wallet = Wallet(mnemonic: "we have all heard how crucial it is to set intentions goals and targets", unblocked: false, stub: Stub())
  }
  
  func unblockWallet() {
    wallet!.unblocked = true
  }
}
