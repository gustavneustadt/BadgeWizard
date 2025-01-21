//
//  LEDPreviewView+Left.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//

extension LEDPreviewView {
    internal func scrollLeft() {
        // Get current pixels array
        let currentPixels = pixels
        
        // Reset position when all pixels have scrolled through
        if Int(currentPosition) > pixels[0].count + 44 {
            currentPosition = 0
        }
        
        let offset = Int(currentPosition)
        for y in 0..<11 {
            for x in 0..<44 {
                let sourceX = x + offset - 44
                displayBuffer.set(x, y, sourceX >= 0 && sourceX < currentPixels[0].count && currentPixels[y][sourceX].isOn)
            }
        }
    }
}
