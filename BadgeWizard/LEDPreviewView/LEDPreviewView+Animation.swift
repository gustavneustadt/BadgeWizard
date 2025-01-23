//
//  LEDPreviewView+asd.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//

extension LEDPreviewView {
    internal func displayAnimation() {
        let badgeWidth = 44
        let totalWidth = pixels[0].count
        let animationSteps = 5 // Match firmware ANI_ANIMATION_STEPS
        
        // Calculate current frame
        let totalFrames = (totalWidth + badgeWidth - 1) / badgeWidth
        let frameIndex = Int(currentPosition / Double(animationSteps)) % totalFrames
        let startX = frameIndex * badgeWidth
        
        // Pre-calculate end position for bounds checking
        let endX = min(startX + badgeWidth, totalWidth)
        
        for y in 0..<11 {
            let row = pixels[y]
            let sourceEndX = min(endX, row.count)
            for x in 0..<badgeWidth {
                let sourceX = startX + x
                displayBuffer.set(x, y, sourceX < sourceEndX ? row[sourceX].isOn : false)
            }
        }
    }
}
