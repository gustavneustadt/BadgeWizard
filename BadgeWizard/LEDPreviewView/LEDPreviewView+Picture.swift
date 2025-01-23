//
//  LEDPreviewView+Picture.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//
import Foundation
// LEDPreviewView+Picture.swift

extension LEDPreviewView {
    internal func displayPicture() {
        let badgeWidth = 44
        let totalWidth = pixels[0].count
        let centerX = badgeWidth / 2
        
        // Calculate frame parameters
        let frameSteps = badgeWidth
        let totalFrames = (totalWidth + badgeWidth - 1) / badgeWidth + 1
        let currentFrame = Int(currentPosition) / frameSteps % totalFrames
        let step = Int(currentPosition) % frameSteps
        
        // Handle final frame differently (picture out animation)
        if currentFrame == totalFrames - 1 {
            pictureOut(step: step, centerX: centerX)
            return
        }
        
        // Calculate reveal range from center
        let range = step % badgeWidth
        guard range <= badgeWidth / 2 else {
            displayFrame(at: currentFrame)
            return
        }
        
        let startX = currentFrame * badgeWidth
        
        // Clear buffer before drawing
        displayBuffer.clear()
        
        // Draw content from center outwards
        for i in 0...range {
            let leftX = centerX - i
            let rightX = centerX + i - 1
            
            for y in 0..<11 {
                if leftX >= 0 {
                    let sourceX = startX + leftX
                    if sourceX < totalWidth {
                        displayBuffer.set(leftX, y, pixels[y][sourceX].isOn)
                    }
                }
                
                if rightX < badgeWidth {
                    let sourceX = startX + rightX
                    if sourceX < totalWidth {
                        displayBuffer.set(rightX, y, pixels[y][sourceX].isOn)
                    }
                }
            }
        }
        
        // Draw reveal line
        if range + 1 < badgeWidth {
            for y in 0..<11 {
                if centerX + range < badgeWidth {
                    displayBuffer.set(centerX + range, y, true)
                }
                if centerX - range - 1 >= 0 {
                    displayBuffer.set(centerX - range - 1, y, true)
                }
            }
        }
    }
    
    private func pictureOut(step: Int, centerX: Int) {
        guard step <= centerX else { return }
        
        // Clear pixels from center outwards
        for i in 0...step {
            let leftX = centerX - i
            let rightX = centerX + i - 1
            
            for y in 0..<11 {
                if leftX >= 0 {
                    displayBuffer.set(leftX, y, false)
                }
                if rightX < 44 {
                    displayBuffer.set(rightX, y, false)
                }
            }
        }
        
        // Draw closing line
        if step + 1 < 44 {
            for y in 0..<11 {
                if centerX + step < 44 {
                    displayBuffer.set(centerX + step, y, true)
                }
                if centerX - step - 1 >= 0 {
                    displayBuffer.set(centerX - step - 1, y, true)
                }
            }
        }
    }
    
    private func displayFrame(at index: Int) {
        let startX = index * 44
        for y in 0..<11 {
            for x in 0..<44 {
                let sourceX = startX + x
                if sourceX < pixels[0].count {
                    displayBuffer.set(x, y, pixels[y][sourceX].isOn)
                }
            }
        }
    }
}
