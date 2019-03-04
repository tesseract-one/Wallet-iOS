//
//  SendFundsViewModel.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit

class SendFundsViewModel: ViewModel, RoutableViewModelProtocol {
    let goBack = SafePublishSubject<Void>()
    let goToView = SafePublishSubject<ToView>()
    
    let scanQr = SafePublishSubject<Void>()
    
    let closeModal = SafePublishSubject<Void>()
    
    let address = Property<String?>(nil)
    
    let walletService: WalletService
    let ethWeb3Service: EthereumWeb3Service
    let changeRateService: ChangeRateService
    
    init(walletService: WalletService, ethWeb3Service: EthereumWeb3Service,
         changeRateService: ChangeRateService) {
        
        self.walletService = walletService
        self.ethWeb3Service = ethWeb3Service
        self.changeRateService = changeRateService
        
        super.init()
        
        let scanQrContext = ScanQRViewControllerContext()
        scanQr.map {
            (name: "ScanQR", context: scanQrContext)
        }.bind(to: goToView).dispose(in: bag)
        
        scanQrContext.cancel.bind(to: closeModal).dispose(in: bag)
        let qrAddress = scanQrContext.qrCode.filter {
            $0.hasPrefix("ethereum:")
        }
        .map { String($0[$0.index($0.startIndex, offsetBy: "ethereum:".count)...]) }
        
        qrAddress.bind(to: address).dispose(in: bag)
        qrAddress.map { _ in }.bind(to: closeModal).dispose(in: bag)
    }
}
