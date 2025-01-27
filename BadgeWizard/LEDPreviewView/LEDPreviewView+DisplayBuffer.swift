//
//  LEDPreviewView+DisplayBuffer.swift
//  BadgeWizard
//
//  Created by Gustav on 21.01.25.
//
import SwiftUI

class DisplayBuffer: ObservableObject {
    var data: UnsafeMutableBufferPointer<UInt64>
    
    init() {
        // Use UInt64 to store 64 bits per integer, reducing memory usage
        let rows = 11
        let cols = (44 + 63) / 64  // Round up to nearest 64
        let buffer = UnsafeMutableBufferPointer<UInt64>.allocate(capacity: rows * cols)
        buffer.initialize(repeating: 0)
        self.data = buffer
    }
    
    func set(_ x: Int, _ y: Int, _ value: Bool) {
        let wordIndex = (y * ((44 + 63) / 64)) + (x / 64)
        let bitIndex = x % 64
        if value {
            data[wordIndex] |= (1 << bitIndex)
        } else {
            data[wordIndex] &= ~(1 << bitIndex)
        }
    }
    
    func get(_ x: Int, _ y: Int) -> Bool {
        let wordIndex = (y * ((44 + 63) / 64)) + (x / 64)
        let bitIndex = x % 64
        return (data[wordIndex] & (1 << bitIndex)) != 0
    }
    
    func clear() {
        data.update(repeating: 0)
    }
}
