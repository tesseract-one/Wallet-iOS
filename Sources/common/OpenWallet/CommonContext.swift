//
//  CommonContext.swift
//  Tesseract
//
//  Created by Yehor Popovych on 5/21/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit

protocol CommonContext: class {
    var wallet: Property<WalletViewModel?> { get }
    var activeAccount: Property<AccountViewModel?> { get }
    
    var walletService: WalletService { get }
    var ethereumWeb3Service: EthereumWeb3Service { get }
    var changeRateService: ChangeRateService { get }
    var passwordService: KeychainPasswordService { get }
    
    var errorNode: SafePublishSubject<Swift.Error> { get }
    
    var settings: Settings { get }
    
    var isApplicationLoaded: Property<Bool> { get }
}
