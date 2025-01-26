//
//  LEDPreviewView+Fixed.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//
import Foundation

extension LEDPreviewView {
    internal func displayFixed() {
        let badgeWidth = 44
        let totalWidth = pixels[0].count
        
        // Calculate which frame to show based on current position
        let frameWidth = badgeWidth
        let totalFrames = (totalWidth + frameWidth - 1) / frameWidth
        let currentFrame = (animationStep / badgeWidth) % totalFrames
        
        // Calculate starting x position for current frame
        let startX = currentFrame * frameWidth
        
        // Draw the current frame
        for y in 0..<11 {
            for x in 0..<badgeWidth {
                let sourceX = startX + x
                if sourceX < totalWidth {
                    displayBuffer.set(x, y, pixels[y][sourceX].isOn)
                }
            }
        }
    }
}
