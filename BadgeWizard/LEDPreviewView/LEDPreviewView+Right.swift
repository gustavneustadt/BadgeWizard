//
//  LEDPreviewView+Right.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//

extension LEDPreviewView {
    internal func scrollRight() {
        let badgeWidth = 44
        let totalWidth = pixels[0].count
        
        // Calculate total steps needed for one complete scroll
        let totalSteps = totalWidth + badgeWidth
        
        // Get current scroll position, moving in opposite direction from left scroll
        let scrollPosition = totalSteps - (animationStep % totalSteps)
        
        // Clear buffer and prepare for new frame
        displayBuffer.clear()
        
        // Draw the current frame
        for y in 0..<11 {
            for x in 0..<badgeWidth {
                // Calculate source position accounting for scroll
                let sourceX = x + scrollPosition - badgeWidth
                
                // Only draw if we're within bounds of source pixels
                if sourceX >= 0 && sourceX < totalWidth {
                    displayBuffer.set(x, y, pixels[y][sourceX].isOn)
                }
            }
        }
    }
}
