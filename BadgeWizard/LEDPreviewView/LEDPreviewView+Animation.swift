//
//  LEDPreviewView+asd.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//

extension LEDPreviewView {
    func getTotalStepsForAnimation() -> Int {
        let badgeWidth = 44
        let totalWidth = pixels[0].count
        let animationSteps = 5  // ANI_ANIMATION_STEPS from firmware
        
        let totalFrames = (totalWidth + badgeWidth - 1) / badgeWidth
        
        return animationSteps * totalFrames
    }
    
    internal func displayAnimation() {
        let badgeWidth = 44
        let totalWidth = pixels[0].count
        let animationSteps = 5 // ANI_ANIMATION_STEPS from firmware
        
        // Calculate frames like firmware does
        let totalFrames = (totalWidth + badgeWidth - 1) / badgeWidth
        guard totalFrames > 0 else { return }
        // Use integer step counting like firmware
        let step = animationStep
        let frameIndex = (step / animationSteps) % totalFrames
        let startX = frameIndex * badgeWidth
        
        // Draw current frame
        for y in 0..<11 {
            let row = pixels[y]
            for x in 0..<badgeWidth {
                let sourceX = startX + x
                displayBuffer.set(x, y, sourceX < row.count ? row[sourceX] == true : false)
            }
        }
    }
}
