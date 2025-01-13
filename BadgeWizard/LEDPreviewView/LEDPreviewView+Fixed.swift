//
//  LEDPreviewView+Fixed.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//
import Foundation

extension LEDPreviewView {
    internal func displayFixed(_ buffer: inout [[Bool]]) {
        let badgeHeight = 11
        let badgeWidth = 44
        let newGridWidth = pixels[0].count
        
        // For images smaller than or equal to badge width, display centered
        if newGridWidth <= badgeWidth {
            // Clear the entire buffer first
            for i in 0..<badgeHeight {
                for j in 0..<badgeWidth {
                    buffer[i][j] = false
                }
            }
            
            // Calculate center offset
            let offset = (badgeWidth - newGridWidth) / 2
            
            // Display the image centered
            for y in 0..<badgeHeight {
                for x in 0..<badgeWidth {
                    let sourceX = x - offset
                    if sourceX >= 0 && sourceX < newGridWidth {
                        buffer[y][x] = pixels[y][sourceX].isOn
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
        
        // Clear the entire buffer before displaying the new frame
        for i in 0..<badgeHeight {
            for j in 0..<badgeWidth {
                buffer[i][j] = false
            }
        }
        
        // Calculate center offset for this frame
        let offset = (badgeWidth - currentFrameWidth) / 2
        
        // Display the current frame centered
        for y in 0..<badgeHeight {
            for x in 0..<badgeWidth {
                let sourceX = x - offset
                let absoluteSourceX = startCol + sourceX
                if sourceX >= 0 && sourceX < currentFrameWidth && absoluteSourceX < newGridWidth {
                    buffer[y][x] = pixels[y][absoluteSourceX].isOn
                }
            }
        }
    }
}
