//
//  LEDPreviewView+Marquee.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//
extension LEDPreviewView {
    internal func applyMarquee() {
        let pattern = 0b000100010001  // Original pattern from C code
        let step = Int(marqueeStep)
        
        for x in 0..<44 {
            // Clear existing edges
            displayBuffer.set(x, 0, false)   // Top edge
            displayBuffer.set(x, 10, false)  // Bottom edge
            
            // Bottom edge - moving right to left
            let bottomBit = (pattern & (1 << ((step + x) & 3))) != 0
            displayBuffer.set(x, 0, bottomBit)
            
            // Top edge - moving left to right
            let topBit = (pattern & (1 << ((-step + x) & 3))) != 0
            displayBuffer.set(x, 10, topBit)
        }
        
        // Add vertical edges
        for y in 1..<10 {
            // Left edge - moving down
            let leftBit = (pattern & (1 << ((step + y) & 3))) != 0
            displayBuffer.set(43, y, leftBit)
            
            // Right edge - moving up
            let rightBit = (pattern & (1 << ((-step + y) & 3))) != 0
            displayBuffer.set(0, y, rightBit)
        }
    }
}
