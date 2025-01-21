//
//  LEDPreviewView+Fixed.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//
import Foundation

extension LEDPreviewView {
    internal func displayFixed() {
        let badgeHeight = 11
        let badgeWidth = 44
        let newGridWidth = pixels[0].count
        
        // For images smaller than or equal to badge width, display centered
        if newGridWidth <= badgeWidth {
            // Clear the buffer
            displayBuffer.clear()
            
            // Calculate center offset
            let offset = (badgeWidth - newGridWidth) / 2
            
            // Display the image centered
            for y in 0..<badgeHeight {
                for x in 0..<badgeWidth {
                    let sourceX = x - offset
                    if sourceX >= 0 && sourceX < newGridWidth {
                        displayBuffer.set(x, y, pixels[y][sourceX].isOn)
                    }
                }
            }
            return
        }
        
        // For larger images that need to be split into frames
        // Calculate how many complete frames we need
        let framesCount = Int(ceil(Double(newGridWidth) / Double(badgeWidth)))
        
        // Get current frame index
        let currentFrameIndex = Int(currentPosition) % framesCount
        
        // Calculate the starting column for the current frame
        let startCol = currentFrameIndex * badgeWidth
        
        // Calculate the width of the current frame
        let remainingWidth = newGridWidth - startCol
        let currentFrameWidth = min(badgeWidth, remainingWidth)
        
        // Clear the buffer
        displayBuffer.clear()
        
        // Calculate center offset for this frame
        let offset = (badgeWidth - currentFrameWidth) / 2
        
        // Display the current frame centered
        for y in 0..<badgeHeight {
            for x in 0..<badgeWidth {
                let sourceX = x - offset
                let absoluteSourceX = startCol + sourceX
                if sourceX >= 0 && sourceX < currentFrameWidth && absoluteSourceX < newGridWidth {
                    displayBuffer.set(x, y, pixels[y][absoluteSourceX].isOn)
                }
            }
        }
    }
}
