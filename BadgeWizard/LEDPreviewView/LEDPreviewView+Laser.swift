//
//  LEDPreviewView+asd.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//
import Foundation

extension LEDPreviewView {
    internal func displayLaser() {
        let badgeWidth = 44
        let totalWidth = pixels[0].count
        
        // Calculate frame parameters
        let frameSteps = badgeWidth * 3 // in-still-out phases
        let totalFrames = (totalWidth + badgeWidth - 1) / badgeWidth
        let currentFrameIndex = animationStep / frameSteps % totalFrames
        let step = animationStep % frameSteps
        
        // Determine animation phase
        if step < badgeWidth {
            // Laser in phase
            laserIn(currentFrameIndex: currentFrameIndex, step: step)
        } else if step < badgeWidth * 2 {
            // Still phase
            displayFrame(at: currentFrameIndex)
        } else {
            // Laser out phase
            laserOut(currentFrameIndex: currentFrameIndex, step: step - badgeWidth * 2)
        }
    }
    
    private func laserIn(currentFrameIndex: Int, step: Int) {
        let badgeWidth = 44
        let startX = currentFrameIndex * badgeWidth
        let sweepPosition = step % badgeWidth
        
        for y in 0..<11 {
            // Draw revealed content up to sweep position
            for x in 0..<sweepPosition {
                let sourceX = startX + x
                if sourceX < pixels[0].count {
                    displayBuffer.set(x, y, pixels[y][sourceX].isOn)
                }
            }
            
            // Draw laser line
            for x in sweepPosition..<badgeWidth {
                if startX + sweepPosition < pixels[0].count {
                    displayBuffer.set(x, y, pixels[y][startX + sweepPosition].isOn)
                }
            }
        }
    }
    
    private func laserOut(currentFrameIndex: Int, step: Int) {
        let badgeWidth = 44
        let startX = currentFrameIndex * badgeWidth
        let sweepPosition = step % badgeWidth
        
        for y in 0..<11 {
            // Draw content after sweep position
            for x in sweepPosition..<badgeWidth {
                let sourceX = startX + x
                if sourceX < pixels[0].count {
                    displayBuffer.set(x, y, pixels[y][sourceX].isOn)
                }
            }
            
            // Draw laser line
            for x in 0..<sweepPosition {
                if startX + sweepPosition < pixels[0].count {
                    displayBuffer.set(x, y, pixels[y][startX + sweepPosition].isOn)
                }
            }
        }
    }
    
    private func displayFrame(at index: Int) {
        let badgeWidth = 44
        let startX = index * badgeWidth
        
        for y in 0..<11 {
            for x in 0..<badgeWidth {
                let sourceX = startX + x
                if sourceX < pixels[0].count {
                    displayBuffer.set(x, y, pixels[y][sourceX].isOn)
                }
            }
        }
    }
}
