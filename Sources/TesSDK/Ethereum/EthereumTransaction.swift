//
//  EthereumTransaction.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/14/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

private enum DataItem {
    case bytes(Data)
    case array(Array<DataItem>)
    
    enum Error: Swift.Error {
        case inputTooLong
    }
    
    func encode() throws -> Data {
        switch self {
        case .bytes(let b):
            return try encodeBytes(b)
        case .array(let a):
            return try encodeArray(a)
        }
    }
    
    private func encodeArray(_ elements: Array<DataItem>) throws -> Data {
        var bytes = Data()
        for item in elements {
            try bytes.append(contentsOf: item.encode())
        }
        let combinedCount = bytes.count
        
        if combinedCount <= 55 {
            let sign: UInt8 = 0xc0 + UInt8(combinedCount)
            // If the total payload of a list (i.e. the combined length of all its items being RLP encoded)
            // is 0-55 bytes long, the RLP encoding consists of a single byte with value 0xc0 plus
            // the length of the list followed by the concatenation of the RLP encodings of the items.
            bytes.insert(sign, at: 0)
            return bytes
        } else {
            // If the total payload of a list is more than 55 bytes long, the RLP encoding consists of
            // a single byte with value 0xf7 plus the length in bytes of the length of the payload
            // in binary form, followed by the length of the payload, followed by the concatenation of
            // the RLP encodings of the items.
            let length = uintToBytes(UInt(bytes.count))
            
            let lengthCount = length.count
            guard lengthCount <= 0xff - 0xf7 else {
                throw Error.inputTooLong
            }
            
            let sign: UInt8 = 0xf7 + UInt8(lengthCount)
            
            for i in (0 ..< length.count).reversed() {
                bytes.insert(length[i], at: 0)
            }
            
            bytes.insert(sign, at: 0)
            
            return bytes
        }
    }
    
    private func encodeBytes(_ bytes: Data) throws -> Data {
        var bytes = bytes
        if bytes.count == 1 && bytes[0] >= 0x00 && bytes[0] <= 0x7f {
            // For a single byte whose value is in the [0x00, 0x7f] range, that byte is its own RLP encoding.
            return bytes
        } else if bytes.count <= 55 {
            // bytes.count is less than or equal 55 so casting is safe
            let sign: UInt8 = 0x80 + UInt8(bytes.count)
            
            // If a string is 0-55 bytes long, the RLP encoding consists of a single byte
            // with value 0x80 plus the length of the string followed by the string.
            bytes.insert(sign, at: 0)
            return bytes
        } else {
            // If a string is more than 55 bytes long, the RLP encoding consists of a single byte
            // with value 0xb7 plus the length in bytes of the length of the string in binary form,
            // followed by the length of the string, followed by the string.
            let length = uintToBytes(UInt(bytes.count))
            
            let lengthCount = length.count
            guard lengthCount <= 0xbf - 0xb7 else {
                // This only really happens if the byte count of the length of the bytes array is
                // greater than or equal 0xbf - 0xb7. This is because 0xbf is the maximum allowed
                // signature byte for this type if rlp encoding.
                throw Error.inputTooLong
            }
            
            let sign: UInt8 = 0xb7 + UInt8(lengthCount)
            
            for i in (0 ..< length.count).reversed() {
                bytes.insert(length[i], at: 0)
            }
            
            bytes.insert(sign, at: 0)
            
            return bytes
        }
    }
    
    // big-endian
    private func uintToBytes(_ int: UInt) -> Data {
        let byteMask: UInt = 0b1111_1111
        let size = MemoryLayout<UInt>.size
        var copy = int
        var bytes: Data = Data()
        for _ in 1...size {
            bytes.insert(UInt8(UInt64(copy & byteMask)), at: 0)
            copy = copy >> 8
        }
        return bytes.trimmedLeadingZeros
    }
}

extension Data {
    var trimmedLeadingZeros: Data {
        // trim leading zeros
        var from = 0
        while from < count-1 && self[from] == 0x00 {
            from += 1
        }
        return self[from...]
    }
}

public struct EthereumAddress: Codable, RawRepresentable {
    public typealias RawValue = Data
    
    public let rawValue: Data
    
    // MARK: - Initialization
    /**
     * Initializes this instance of `EthereumAddress` with the given `hex` String.
     *
     * `hex` must be either 40 characters (20 bytes) or 42 characters (with the 0x hex prefix) long.
     *
     * If `eip55` is set to `true`, a checksum check will be done over the given hex string as described
     * in https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md
     *
     * - parameter hex: The ethereum address as a hex string. Case sensitive iff `eip55` is set to true.
     * - parameter eip55: Whether to check the checksum as described in eip 55 or not.
     *
     * - throws: EthereumAddress.Error.addressMalformed if the given hex string doesn't fulfill the conditions described above.
     *           EthereumAddress.Error.checksumWrong iff `eip55` is set to true and the checksum is wrong.
     */
    public init(hex: String, eip55: Bool) throws {
        // Check length
        guard hex.count == 40 || hex.count == 42 else {
            throw Error.addressMalformed
        }
        
        var hex = hex
        
        // Check prefix
        if hex.count == 42 {
            let s = hex.index(hex.startIndex, offsetBy: 0)
            let e = hex.index(hex.startIndex, offsetBy: 2)
            
            guard String(hex[s..<e]) == "0x" else {
                throw Error.addressMalformed
            }
            
            // Remove prefix
            let hexStart = hex.index(hex.startIndex, offsetBy: 2)
            hex = String(hex[hexStart...])
        }
        
        // Check hex
        guard hex.rangeOfCharacter(from: EthereumAddress.hexadecimals.inverted) == nil else {
            throw Error.addressMalformed
        }
        
        // Create address bytes
        var addressBytes = Data()
        for i in stride(from: 0, to: hex.count, by: 2) {
            let s = hex.index(hex.startIndex, offsetBy: i)
            let e = hex.index(hex.startIndex, offsetBy: i + 2)
            
            guard let b = UInt8(String(hex[s..<e]), radix: 16) else {
                throw Error.addressMalformed
            }
            addressBytes.append(b)
        }
        self.rawValue = addressBytes
        
        // EIP 55 checksum
        // See: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md
        if eip55 {
            let hash = SHA3(variant: .keccak256).calculate(for: Array(hex.lowercased().utf8))
            
            for i in 0..<hex.count {
                let charString = String(hex[hex.index(hex.startIndex, offsetBy: i)])
                if charString.rangeOfCharacter(from: EthereumAddress.hexadecimalNumbers) != nil {
                    continue
                }
                
                let bytePos = (4 * i) / 8
                let bitPos = (4 * i) % 8
                guard bytePos < hash.count && bitPos < 8 else {
                    throw Error.addressMalformed
                }
                let bit = (hash[bytePos] >> (7 - UInt8(bitPos))) & 0x01
                
                if charString.lowercased() == charString && bit == 1 {
                    throw Error.checksumWrong
                } else if charString.uppercased() == charString && bit == 0 {
                    throw Error.checksumWrong
                }
            }
        }
    }
    
    /**
     * Initializes a new instance of `EthereumAddress` with the given raw Bytes array.
     *
     * `rawAddress` must be exactly 20 bytes long.
     *
     * - parameter rawAddress: The raw address as a byte array.
     *
     * - throws: EthereumAddress.Error.addressMalformed if the rawAddress array is not 20 bytes long.
     */
    public init(rawAddress: Data) throws {
        guard rawAddress.count == 20 else {
            throw Error.addressMalformed
        }
        self.rawValue = rawAddress
    }
    
    public init?(rawValue: Data) {
        do {
            try self.init(rawAddress: rawValue)
        } catch {
            return nil
        }
    }
    
    // MARK: - Convenient functions
    /**
     * Returns this ethereum address as a hex string.
     *
     * Adds the EIP 55 mixed case checksum if `eip55` is set to true.
     *
     * - parameter eip55: Whether to add the mixed case checksum as described in eip 55.
     *
     * - returns: The hex string representing this `EthereumAddress`.
     *            Either lowercased or mixed case (checksumed) depending on the parameter `eip55`.
     */
    public func hex(eip55: Bool) -> String {
        var hex = "0x"
        if !eip55 {
            for b in rawValue {
                hex += String(format: "%02x", b)
            }
        } else {
            var address = ""
            for b in rawValue {
                address += String(format: "%02x", b)
            }
            let hash = SHA3(variant: .keccak256).calculate(for: Array(address.utf8))
            
            for i in 0..<address.count {
                let charString = String(address[address.index(address.startIndex, offsetBy: i)])
                
                if charString.rangeOfCharacter(from: EthereumAddress.hexadecimalNumbers) != nil {
                    hex += charString
                    continue
                }
                
                let bytePos = (4 * i) / 8
                let bitPos = (4 * i) % 8
                let bit = (hash[bytePos] >> (7 - UInt8(bitPos))) & 0x01
                
                if bit == 1 {
                    hex += charString.uppercased()
                } else {
                    hex += charString.lowercased()
                }
            }
        }
        
        return hex
    }
    
    // MARK: - Errors
    public enum Error: Swift.Error {
        
        case addressMalformed
        case checksumWrong
    }
    
    private static let hexadecimals: CharacterSet = [
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "a", "b", "c", "d", "e", "f", "A", "B", "C", "D", "E", "F"
    ]
    
    private static let hexadecimalNumbers: CharacterSet = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
}

public struct EthereumTransaction {
    /// The number of transactions made prior to this one
    public var nonce: BigUInt
    
    /// Gas price provided Wei
    public var gasPrice: BigUInt
    
    /// Gas limit provided
    public var gas: BigUInt
    
    // Address of the sender
    public var from: EthereumAddress
    
    /// Address of the receiver
    public var to: EthereumAddress?
    
    /// Value to transfer provided in Wei
    public var value: BigUInt
    
    /// Input data for this transaction
    public var data: Data
    
    public init(nonce: BigUInt, gasPrice: BigUInt, gas: BigUInt, from: EthereumAddress, to: EthereumAddress? = nil, value: BigUInt, data: Data? = nil) {
        self.nonce = nonce
        self.gasPrice = gasPrice
        self.gas = gas
        self.from = from
        self.to = to
        self.value = value
        self.data = data ?? Data()
    }
    
    public func rawData(chainId: BigUInt) throws -> Data {
        let item: DataItem = .array([
            .bytes(nonce.serialize().trimmedLeadingZeros),
            .bytes(gasPrice.serialize().trimmedLeadingZeros),
            .bytes(gas.serialize().trimmedLeadingZeros),
            .bytes(to?.rawValue ?? Data()),
            .bytes(value.serialize().trimmedLeadingZeros),
            .bytes(data),
            .bytes(chainId.serialize().trimmedLeadingZeros),
            .bytes(BigUInt(0).serialize().trimmedLeadingZeros),
            .bytes(BigUInt(0).serialize().trimmedLeadingZeros)
        ])
        return try item.encode()
    }
}
