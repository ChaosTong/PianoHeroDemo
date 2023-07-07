//
//  Byte.swift
//  MidiParser
//
//  Created by Yuma Matsune on 2018/07/10.
//  Copyright © 2018 Yuma Matsune. All rights reserved.
//

import Foundation

typealias Byte = UInt8
typealias Bytes = [Byte]

protocol Decimalable {
    associatedtype T
    
    var decimal: T { get }
}

// 2 Byte
struct Word {
    private var value: (UInt8, UInt8)
    
    init(byte1: UInt8, byte2: UInt8) {
        value = (byte1, byte2)
    }
    
    var val: UInt16 {
        return UInt16(value.0) * 16 + UInt16(value.1)
    }
}

extension Word: Decimalable {
    
    var decimal: UInt16 {
        let hexToDecimal = UInt16(16)
        return UInt16(value.0) * hexToDecimal + UInt16(value.1)
    }
    
}

// 4 Byte
struct DWord {
    private var value: (UInt8, UInt8, UInt8, UInt8)
    
    init(byte1: UInt8, byte2: UInt8, byte3: UInt8, byte4: UInt8) {
        value = (byte1, byte2, byte3, byte4)
    }
    
    var val: UInt32 {
        return UInt32(value.0) * 16 * 16 * 16
            + UInt32(value.1) * 16 * 16
            + UInt32(value.2) * 16
            + UInt32(value.3)
    }
}

extension DWord: Decimalable {
    var decimal: UInt32 {
        let hexToDecimal = UInt32(16)
        
        return UInt32(value.0) * hexToDecimal * hexToDecimal * hexToDecimal
            + UInt32(value.1) * hexToDecimal * hexToDecimal
            + UInt32(value.2) * hexToDecimal
            + UInt32(value.3)
    }
}

extension Collection where Element == Byte {
    var string: String {
        return String(bytes: self, encoding: .utf8) ?? ""
    }
}
