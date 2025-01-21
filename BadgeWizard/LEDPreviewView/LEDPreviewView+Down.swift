//
//  LEDPreviewView+Down.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//
import Foundation
extension LEDPreviewView {
    internal func scrollDown() {
        let badgeHeight = 11
        let badgeWidth = 44
        let newGridWidth = pixels[0].count
        
        // Calculate frames for wide images
        let framesCount = Int(ceil(Double(newGridWidth) / Double(badgeWidth)))
        let totalSteps = badgeHeight * 3 // Steps for one complete scroll
        
        // Calculate which frame we're currently showing
        let frameCounter = Int(currentPosition / Double(totalSteps))
        let currentFrameIndex = frameCounter % framesCount
        
        // Calculate the current step within the animation cycle
        let currentStep = Int(currentPosition) % totalSteps
        
        // Calculate the starting column for the current frame
        let startCol = currentFrameIndex * badgeWidth
        let remainingWidth = newGridWidth - startCol
        let currentFrameWidth = min(badgeWidth, remainingWidth)
        
        // Clear the buffer first
        displayBuffer.clear()
        
        // Apply scrolling animation based on current step
        if currentStep < badgeHeight { // Scrolling in
            for y in 0..<badgeHeight {
                for x in 0..<currentFrameWidth {
                    let sourceY = y + (badgeHeight - currentStep)
                    if sourceY >= 0 && sourceY < badgeHeight {
                        let sourceX = startCol + x
                        if sourceX < newGridWidth {
                            displayBuffer.set(x, y, pixels[sourceY][sourceX].isOn)
                        }
                    }
                }
            }
        } else if currentStep < badgeHeight * 2 { // Still
            for y in 0..<badgeHeight {
                for x in 0..<currentFrameWidth {
                    let sourceX = startCol + x
                    if sourceX < newGridWidth {
                        displayBuffer.set(x, y, pixels[y][sourceX].isOn)
                    }
                }
            }
        } else { // Scrolling out
            for y in 0..<badgeHeight {
                for x in 0..<currentFrameWidth {
                    let sourceY = y - (currentStep - (badgeHeight * 2))
                    if sourceY >= 0 && sourceY < badgeHeight {
                        let sourceX = startCol + x
                        if sourceX < newGridWidth {
                            displayBuffer.set(x, y, pixels[sourceY][sourceX].isOn)
                        }
                    }
                }
            }
        }
    }
}
