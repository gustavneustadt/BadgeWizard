//
//  LEDPreviewView+Picture.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//
import Foundation

extension LEDPreviewView {
    internal func displayPicture() {
        let badgeHeight = 11
        let badgeWidth = 44
        let newGridWidth = pixels[0].count
        
        // For images smaller than or equal to badge width, display left-aligned
        if newGridWidth <= badgeWidth {
            // Clear the buffer
            displayBuffer.clear()
            
            // Display the image left-aligned
            for i in 0..<badgeHeight {
                for j in 0..<newGridWidth {
                    displayBuffer.set(j, i, pixels[i][j].isOn)
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
        
        // Clear the buffer
        displayBuffer.clear()
        
        // Display the current frame left-aligned
        for i in 0..<badgeHeight {
            for j in 0..<badgeWidth {
                let sourceCol = startCol + j
                if sourceCol < newGridWidth {
                    displayBuffer.set(j, i, pixels[i][sourceCol].isOn)
                }
            }
        }
    }
}
