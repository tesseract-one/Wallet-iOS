//
//  ScanQRViewController.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class ScanQRViewControllerContext: RouterContextProtocol {
    let qrCode = PassthroughSubject<String, Never>()
    let cancel = PassthroughSubject<Void, Never>()
}

class ScanQRViewController: UIViewController, RouterViewProtocol {
    @IBOutlet weak var qrCodeScannerView: QRCodeScannerView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var qrCode: PassthroughSubject<String, Never>!
    var cancel: PassthroughSubject<Void, Never>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qrCodeScannerView.qrCodeValue
            .bind(to: qrCode)
            .dispose(in: reactive.bag)
        
        cancelButton.reactive.tap
            .throttle(seconds: 0.3)
            .bind(to: cancel)
            .dispose(in: reactive.bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        qrCodeScannerView.isWorking.send(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        qrCodeScannerView.isWorking.send(false)
    }
}

extension ScanQRViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let qrContext = context.get(context: ScanQRViewControllerContext.self)!
        qrCode = qrContext.qrCode
        cancel = qrContext.cancel
    }
}

