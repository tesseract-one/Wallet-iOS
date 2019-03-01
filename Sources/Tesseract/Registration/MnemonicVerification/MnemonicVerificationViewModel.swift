//
//  MnemonicVerificationViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import TesSDK

enum MnemonicVerificationError: String {
  case deffierent = "Mnemonics are different"
  case server = "Server error"
}

class MnemonicVerificationViewModel: ViewModel {
  private let mnemonic: String
  private let wallet: Wallet
  private let walletService: WalletService
  
  let doneMnemonicVerificationAction = SafePublishSubject<Void>()
  let mnemonicText = Property<String>("")
  let mnemonicError = Property<MnemonicVerificationError?>(nil)
  let mnemonicVerifiedSuccessfully = Property<Bool?>(nil)
  
  init (mnemonic: String, wallet: Wallet, walletService: WalletService) {
    self.mnemonic = mnemonic
    self.wallet = wallet
    self.walletService = walletService
    
    super.init()

    mnemonicValidator().bind(to: mnemonicError).dispose(in: bag)
    
    setUpMnemonicVerification()
  }
}

extension MnemonicVerificationViewModel {
  
  private func mnemonicValidator() -> SafeSignal<MnemonicVerificationError?> {
    let mnemonic = self.mnemonic
    
    return mnemonicText
      .map { mnemonicText -> MnemonicVerificationError? in
        let trimmedMnemonicText = mnemonicText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedMnemonicText != mnemonic {
          return MnemonicVerificationError.deffierent
        }
        return nil
    }
  }
  
  private func setUpMnemonicVerification() {
    let wallet = self.wallet
    let errors = SafePublishSubject<AnyError>()
    
    doneMnemonicVerificationAction
      .with(weak: mnemonicError)
      .filter { $1.value != nil }
      .map { _ in false }
      .bind(to: mnemonicVerifiedSuccessfully)
      .dispose(in: bag)
    
    
    doneMnemonicVerificationAction
      .with(weak: mnemonicError)
      .filter { $1.value == nil }
      .map { _ in }
      .with(weak: walletService)
      .flatMapLatest { (walletService) -> Signal<Void, AnyError> in
        walletService.setWallet(wallet: wallet)
        return walletService.saveWallet().signal
      }.suppressAndFeedError(into: errors)
      .map { _ in true }
      .bind(to: mnemonicVerifiedSuccessfully)
      .dispose(in: bag)

    errors.map { _ in MnemonicVerificationError.server }
      .bind(to: mnemonicError).dispose(in: bag)
  }
}

