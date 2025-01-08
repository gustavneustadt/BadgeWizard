//
//  LEDPreviewView+Picture.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//
import Foundation

extension LEDPreviewView {
    internal func displayPicture(_ buffer: inout [[Bool]]) {
        let badgeHeight = 11
        let badgeWidth = 44
        let newGridWidth = pixels[0].count
        
        // For images smaller than or equal to badge width, display left-aligned
        if newGridWidth <= badgeWidth {
            // Clear the entire buffer first
            for i in 0..<badgeHeight {
                for j in 0..<badgeWidth {
                    buffer[i][j] = false
                }
            }
            
            // Display the image left-aligned
            for i in 0..<badgeHeight {
                for j in 0..<newGridWidth {
                    buffer[i][j] = pixels[i][j].isOn
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
        
        // Clear the entire buffer before displaying the new frame
        for i in 0..<badgeHeight {
            for j in 0..<badgeWidth {
                buffer[i][j] = false
            }
        }
        
        // Display the current frame left-aligned
        for i in 0..<badgeHeight {
            for j in 0..<badgeWidth {
                let sourceCol = startCol + j
                if sourceCol < newGridWidth {
                    buffer[i][j] = pixels[i][sourceCol].isOn
                }
                // No need for else case as buffer is already cleared
            }
        }
    }
}
