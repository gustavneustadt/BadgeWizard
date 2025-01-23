//
//  LEDPreviewView+Down.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//
import Foundation

extension LEDPreviewView {
    internal func scrollUp() {
        let frameSteps = 33 // in-still-out (11 * 3)
        let framesCount = Int(ceil(Double(pixels[0].count) / 44.0))
        let totalSteps = frameSteps * framesCount
        
        // Reset when complete cycle is done
        if Int(currentPosition) > totalSteps {
            currentPosition = 0
        }
        
        let framePosition = Int(currentPosition) / frameSteps
        let currentStep = Int(currentPosition) % frameSteps
        
        // Starting column for current frame
        let startCol = framePosition * 44
        
        for y in 0..<11 {
            for x in 0..<44 {
                let sourceCol = startCol + x
                if sourceCol >= pixels[0].count { continue }
                
                if currentStep < 11 { // Scrolling up (in)
                    let shiftedY = y + (currentStep - 11)
                    displayBuffer.set(x, y, shiftedY >= 0 && pixels[shiftedY][sourceCol].isOn)
                } else if currentStep < 22 { // Stay still
                    displayBuffer.set(x, y, pixels[y][sourceCol].isOn)
                } else { // Scrolling up (out)
                    let shiftedY = y + (currentStep - 22)
                    displayBuffer.set(x, y, shiftedY < 11 && pixels[shiftedY][sourceCol].isOn)
                }
            }
        }
    }
    
    internal func scrollDown() {
        let frameSteps = 33 // in-still-out (11 * 3)
        let framesCount = Int(ceil(Double(pixels[0].count) / 44.0))
        let totalSteps = frameSteps * framesCount
        
        // Reset when complete cycle is done
        if Int(currentPosition) > totalSteps {
            currentPosition = 0
        }
        
        let framePosition = Int(currentPosition) / frameSteps
        let currentStep = Int(currentPosition) % frameSteps
        
        // Starting column for current frame
        let startCol = framePosition * 44
        
        for y in 0..<11 {
            for x in 0..<44 {
                let sourceCol = startCol + x
                if sourceCol >= pixels[0].count { continue }
                
                if currentStep < 11 { // Scrolling down (in)
                    let shiftedY = y - (currentStep - 11)
                    displayBuffer.set(x, y, shiftedY < 11 && shiftedY >= 0 && pixels[shiftedY][sourceCol].isOn)
                } else if currentStep < 22 { // Stay still
                    displayBuffer.set(x, y, pixels[y][sourceCol].isOn)
                } else { // Scrolling down (out)
                    let shiftedY = y - (currentStep - 22)
                    displayBuffer.set(x, y, shiftedY >= 0 && pixels[shiftedY][sourceCol].isOn)
                }
            }
        }
    }
}
