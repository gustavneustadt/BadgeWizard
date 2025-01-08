//
//  LEDPreviewView+Up.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//
import Foundation

extension LEDPreviewView {
    internal func scrollUp(_ buffer: inout [[Bool]]) {
        let badgeHeight = 11
        let badgeWidth = 44
        let newGridWidth = pixels[0].count
        
        // Calculate frames for wide images
        let framesCount = Int(ceil(Double(newGridWidth) / Double(badgeWidth)))
        
        // Calculate total steps for the complete animation cycle
        let stepsPerFrame = badgeHeight * 3  // Original animation cycle (11 * 3)
        let totalSteps = stepsPerFrame * framesCount
        
        // Get current frame and animation step
        let absoluteStep = Int(currentPosition) % totalSteps
        let currentFrameIndex = absoluteStep / stepsPerFrame
        let currentStep = absoluteStep % stepsPerFrame
        
        // Calculate the starting column for the current frame
        let startCol = currentFrameIndex * badgeWidth
        let remainingWidth = newGridWidth - startCol
        let currentFrameWidth = min(badgeWidth, remainingWidth)
        
        // Clear the buffer
        for y in 0..<badgeHeight {
            for x in 0..<badgeWidth {
                buffer[y][x] = false
            }
        }
        
        // Apply the scrolling animation for the current frame
        if currentStep < badgeHeight { // Scrolling in
            for y in 0..<badgeHeight {
                for x in 0..<currentFrameWidth {
                    let sourceY = y - (badgeHeight - currentStep)
                    let sourceX = startCol + x
                    if sourceY >= 0 && sourceY < badgeHeight && sourceX < newGridWidth {
                        buffer[y][x] = pixels[sourceY][sourceX].isOn
                    }
                }
            }
        } else if currentStep < (badgeHeight * 2) { // Still
            for y in 0..<badgeHeight {
                for x in 0..<currentFrameWidth {
                    let sourceX = startCol + x
                    if sourceX < newGridWidth {
                        buffer[y][x] = pixels[y][sourceX].isOn
                    }
                }
            }
        } else { // Scrolling out
            for y in 0..<badgeHeight {
                for x in 0..<currentFrameWidth {
                    let sourceY = y + (currentStep - (badgeHeight * 2))
                    let sourceX = startCol + x
                    if sourceY >= 0 && sourceY < badgeHeight && sourceX < newGridWidth {
                        buffer[y][x] = pixels[sourceY][sourceX].isOn
                    }
                }
            }
        }
    }
}
