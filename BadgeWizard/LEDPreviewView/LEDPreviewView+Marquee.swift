//
//  LEDPreviewView+Marquee.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//

extension LEDPreviewView {
    
    internal func applyMarquee(_ buffer: inout [[Bool]]) {
        // Cap the speed multiplier for marquee to match hardware limitations (speed 5)
        let cappedSpeedMultiplier = min(speedMultiplier, 0.797) // speed 5 (quick) value
        let step = Int((Double(animationStep) * cappedSpeedMultiplier).rounded()) / 2 % 4
        
        // Create a new buffer just for the display content, excluding border
        var innerBuffer = Array(repeating: Array(repeating: false, count: 44), count: 11)
        
        // Copy the non-border content to the inner buffer
        for i in 1..<10 {
            for j in 1..<43 {
                innerBuffer[i][j] = buffer[i][j]
            }
        }
        
        // Clear the original buffer
        buffer = Array(repeating: Array(repeating: false, count: 44), count: 11)
        
        // Copy back the inner content
        for i in 1..<10 {
            for j in 1..<43 {
                buffer[i][j] = innerBuffer[i][j]
            }
        }
        
        // Apply marquee effect on the borders (counterclockwise)
        for i in 0..<11 {
            for j in 0..<44 {
                let isOnBorder = i == 0 || j == 0 || i == 10 || j == 43
                if isOnBorder {
                    var shouldLight = false
                    
                    // Top edge: right to left
                    if i == 0 {
                        shouldLight = (43 - j) % 4 == step
                    }
                    // Left edge: top to bottom
                    else if j == 0 {
                        shouldLight = i % 4 == step
                    }
                    // Bottom edge: left to right
                    else if i == 10 {
                        shouldLight = j % 4 == step
                    }
                    // Right edge: bottom to top
                    else if j == 43 {
                        shouldLight = (10 - i) % 4 == step
                    }
                    
                    buffer[i][j] = shouldLight
                }
            }
        }
    }
}
