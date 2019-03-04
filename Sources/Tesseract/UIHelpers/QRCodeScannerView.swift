//
//  QRCodeScannerView.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import AVFoundation
import ReactiveKit

class QRCodeScannerView: UIView {
    private let captureSession: AVCaptureSession = AVCaptureSession()
    private var subLayer: CALayer?
    
    let qrCodeValue: SafePublishSubject<String> = SafePublishSubject()
    let isWorking: Property<Bool> = Property(false)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subLayer?.frame = bounds
    }
    
    private func setupCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        guard captureSession.canAddInput(videoInput) else { return }
        captureSession.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        guard captureSession.canAddOutput(metadataOutput) else { return }
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.frame = bounds
        layer.videoGravity = .resizeAspectFill
        subLayer = layer
        self.layer.addSublayer(layer)
        
        isWorking.with(weak: self).observeNext { started, sself in
            if started {
                if !sself.captureSession.isRunning {
                    sself.captureSession.startRunning()
                }
            } else {
                if sself.captureSession.isRunning {
                    sself.captureSession.stopRunning()
                }
            }
        }.dispose(in: reactive.bag)
    }
    
    private func setupView() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] (hasAccess) in
            DispatchQueue.main.async { [weak self] in
                if hasAccess {
                    self?.setupCamera()
                } else if let sself = self {
                    let layer = CATextLayer()
                    layer.string = "NO CAMERA ACCESS"
                    layer.alignmentMode = .center
                    layer.foregroundColor = UIColor.white.cgColor
                    layer.frame = sself.bounds
                    sself.subLayer = layer
                    sself.layer.addSublayer(layer)
                }
            }
        }
    }
}

extension QRCodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            qrCodeValue.next(stringValue)
        }
    }
}
