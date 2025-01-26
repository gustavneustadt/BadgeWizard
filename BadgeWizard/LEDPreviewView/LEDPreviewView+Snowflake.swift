//
//  LEDPreviewView+asd.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//
import Foundation

extension LEDPreviewView {
    internal func displaySnowflake() {
        let badgeHeight = 11
        let badgeWidth = 44
        let newGridWidth = pixels[0].count
        
        // Calculate frames for wide images
        let framesCount = Int(ceil(Double(newGridWidth) / Double(badgeWidth)))
        
        // Calculate steps for animation phases
        let fallInSteps = badgeHeight * 3  // Steps for falling in
        let fallOutSteps = badgeHeight * 3  // Steps for falling out (only used in last chunk)
        
        // Calculate total steps based on chunk position
        let stepsPerNormalChunk = fallInSteps  // Only fall in for normal chunks
        let stepsForLastChunk = fallInSteps + fallOutSteps  // Fall in + fall out for last chunk
        let totalSteps = (stepsPerNormalChunk * (framesCount - 1)) + stepsForLastChunk
        
        // Get current frame and animation step
        let absoluteStep = animationStep % totalSteps
        
        // Calculate which chunk we're on and the step within that chunk
        var currentFrameIndex = 0
        var currentStep = absoluteStep
        
        if absoluteStep < (framesCount - 1) * stepsPerNormalChunk {
            // We're in a normal chunk
            currentFrameIndex = absoluteStep / stepsPerNormalChunk
            currentStep = absoluteStep % stepsPerNormalChunk
        } else {
            // We're in the last chunk
            currentFrameIndex = framesCount - 1
            currentStep = absoluteStep - ((framesCount - 1) * stepsPerNormalChunk)
        }
        
        // Calculate the starting column for the current frame
        let startCol = currentFrameIndex * badgeWidth
        let remainingWidth = newGridWidth - startCol
        let currentFrameWidth = min(badgeWidth, remainingWidth)
        
        // Clear the buffer
        displayBuffer.clear()
        
        // Check if this is the last chunk
        let isLastChunk = currentFrameIndex == framesCount - 1
        
        if isLastChunk {
            // Last chunk: Full animation with fall in and fall out
            let phase1 = currentStep < fallInSteps  // Fall down phase
            let phase2 = currentStep >= fallInSteps // Fall out phase
            
            if phase1 {
                // Falling down phase
                for row in (0..<badgeHeight).reversed() {
                    let fallPosition = currentStep - (badgeHeight - 1 - row) * 2
                    let stoppingPosition = row
                    let actualFallPosition = fallPosition >= stoppingPosition ? stoppingPosition : fallPosition
                    
                    if actualFallPosition >= 0 && actualFallPosition < badgeHeight {
                        for col in 0..<currentFrameWidth {
                            let sourceCol = startCol + col
                            if sourceCol < newGridWidth {
                                displayBuffer.set(col, actualFallPosition, pixels[row][sourceCol].isOn)
                            }
                        }
                    }
                }
            } else if phase2 {
                // Falling out phase
                for row in (0..<badgeHeight).reversed() {
                    let fallOutStartFrame = (badgeHeight - 1 - row) * 2
                    let fallOutPosition = row + (currentStep - fallInSteps - fallOutStartFrame)
                    
                    if fallOutPosition < row {
                        for col in 0..<currentFrameWidth {
                            let sourceCol = startCol + col
                            if sourceCol < newGridWidth {
                                displayBuffer.set(col, row, pixels[row][sourceCol].isOn)
                            }
                        }
                    }
                    
                    if fallOutPosition >= row && fallOutPosition < badgeHeight {
                        if fallOutPosition < badgeHeight {
                            for col in 0..<currentFrameWidth {
                                let sourceCol = startCol + col
                                if sourceCol < newGridWidth {
                                    displayBuffer.set(col, fallOutPosition, pixels[row][sourceCol].isOn)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            // Other chunks: Only fall in
            // Falling down phase
            for row in (0..<badgeHeight).reversed() {
                let fallPosition = currentStep - (badgeHeight - 1 - row) * 2
                let stoppingPosition = row
                let actualFallPosition = fallPosition >= stoppingPosition ? stoppingPosition : fallPosition
                
                if actualFallPosition >= 0 && actualFallPosition < badgeHeight {
                    for col in 0..<currentFrameWidth {
                        let sourceCol = startCol + col
                        if sourceCol < newGridWidth {
                            displayBuffer.set(col, actualFallPosition, pixels[row][sourceCol].isOn)
                        }
                    }
                }
            }
        }
    }
}
