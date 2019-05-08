/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A simple struct that defines the service and access group to be used by the sample apps.
 */

import Foundation
import PromiseKit
import LocalAuthentication

class KeychainPasswordService {
    enum Error: Swift.Error {
        case biometricAuthenticationFailed
    }
    
    enum BiometricType: Equatable {
        case none
        case touch
        case face
        
        init(type: LABiometryType) {
            switch(type) {
            case .touchID: self = .touch
            case .faceID: self = .face
            default: self = .none
            }
        }
    }
    
    enum BiometricalErrors: Swift.Error, Equatable {
        case userCancel
        case userFallback
        case userDisallow
        case biometryLockout
        case retryLimitExceeded
        case internalError(NSError)
        
        init(error: NSError) {
            switch error.code {
            case Int(kLAErrorAuthenticationFailed): self = .retryLimitExceeded
            case Int(kLAErrorBiometryNotAvailable): self = .userDisallow
            case Int(kLAErrorUserCancel): self = .userCancel
            case Int(kLAErrorUserFallback): self = .userFallback
            case Int(kLAErrorBiometryLockout): self = .biometryLockout
            default: self = .internalError(error)
            }
        }
    }
    
    static var serviceName = "wallet"
    //    static let accessGroup = "[YOUR APP ID PREFIX].com.example.apple-samplecode.GenericKeychainShared"
    static var accessGroup: String? = nil
    private static let accountName = "WALLET"
    
    private var passwordItem: KeychainPasswordItem!
    
    func bootstrap() {
        passwordItem = KeychainPasswordItem(
            service: KeychainPasswordService.serviceName,
            account: KeychainPasswordService.accountName,
            accessGroup: KeychainPasswordService.accessGroup
        )
    }
    
    func hasPassword() -> Promise<Bool> {
        let item = passwordItem!
        return Promise().map {
            do {
                _ = try item.readPassword()
            } catch KeychainPasswordItem.KeychainError.noPassword {
                return false
            }
            return true
        }
    }
    
    func canLoadPassword() -> Promise<Bool> {
        if hasBiometrics() {
            return hasPassword()
        }
        return Promise.value(false)
    }
    
    func savePasswordWithBiometrics(password: String) -> Promise<Void> {
        let item = passwordItem!
        return authByBiometrics("Attach your biometric")
            .map { authenticated in
                guard authenticated else { throw Error.biometricAuthenticationFailed }
                return try item.savePassword(password)
            }
    }
    
    func loadPasswordWithBiometrics() -> Promise<String> {
        let item = passwordItem!
        return authByBiometrics("Unlock Wallet")
            .map { authenticated in
                guard authenticated else { throw Error.biometricAuthenticationFailed }
                return try item.readPassword()
            }
    }
    
    func hasBiometrics() -> Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func getBiometricType() -> BiometricType {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            return BiometricType(type: context.biometryType)
        } else {
            return .none
        }
    }
    
    func authByBiometrics(_ localizedReason: String) -> Promise<Bool> {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"
        return Promise { seal in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason) { val, error in
                if val {
                    seal.fulfill(true)
                } else if let error = error {
                    seal.reject(BiometricalErrors(error: error as NSError))
                } else {
                    seal.fulfill(false)
                }
            }
        }
    }
}
