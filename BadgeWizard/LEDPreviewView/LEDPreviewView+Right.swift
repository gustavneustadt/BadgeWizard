//
//  LEDPreviewView+Right.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//
extension LEDPreviewView {
    internal func scrollRight() {
        // Get current pixels array
        let currentPixels = pixels
        
        // reset position when all the pixels scrolled through
        if Int(currentPosition) > currentPixels[0].count + 44 {
            currentPosition = 0
        }
        
        let offset = Int(currentPosition)
        
        for y in 0..<11 {
            for x in 0..<44 {
                let sourceX = currentPixels[0].count - 1 - (offset - x)
                if sourceX >= 0 && sourceX < currentPixels[0].count {
                    displayBuffer.set(x, y, currentPixels[y][sourceX].isOn)
                } else {
                    displayBuffer.set(x, y, false)
                }
            }
        }
    }
}
