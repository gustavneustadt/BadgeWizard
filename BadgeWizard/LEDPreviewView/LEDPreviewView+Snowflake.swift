//
//  LEDPreviewView+asd.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//
extension LEDPreviewView {
    internal func displaySnowflake(_ buffer: inout [[Bool]]) {
        let badgeHeight = 11
        let badgeWidth = 44
        let totalAnimationLength = badgeHeight * 16
        let currentStep = Int(currentPosition) % totalAnimationLength
        
        let horizontalOffset = (badgeWidth - pixels[0].count) / 2
        
        let phase1 = currentStep < badgeHeight * 4
        let phase2 = currentStep >= badgeHeight * 4 && currentStep < badgeHeight * 8
        
        if phase1 {
            for row in (0..<badgeHeight).reversed() {
                let fallPosition = currentStep - (badgeHeight - 1 - row) * 2
                let stoppingPosition = row
                let actualFallPosition = fallPosition >= stoppingPosition ? stoppingPosition : fallPosition
                
                if actualFallPosition >= 0 && actualFallPosition < badgeHeight {
                    for col in 0..<badgeWidth {
                        let sourceCol = col - horizontalOffset
                        if sourceCol >= 0 && sourceCol < pixels[0].count {
                            buffer[actualFallPosition][col] = pixels[row][sourceCol].isOn
                        }
                    }
                }
            }
        } else if phase2 {
            for row in (0..<badgeHeight).reversed() {
                let fallOutStartFrame = (badgeHeight - 1 - row) * 2
                let fallOutPosition = row + (currentStep - badgeHeight * 4 - fallOutStartFrame)
                
                if fallOutPosition < row {
                    for col in 0..<badgeWidth {
                        let sourceCol = col - horizontalOffset
                        if sourceCol >= 0 && sourceCol < pixels[0].count {
                            buffer[row][col] = pixels[row][sourceCol].isOn
                        }
                    }
                }
                
                if fallOutPosition >= row && fallOutPosition < badgeHeight {
                    for col in 0..<badgeWidth {
                        buffer[row][col] = false
                        
                        let sourceCol = col - horizontalOffset
                        if sourceCol >= 0 && sourceCol < pixels[0].count && fallOutPosition < badgeHeight {
                            buffer[fallOutPosition][col] = pixels[row][sourceCol].isOn
                        }
                    }
                }
            }
        }
    }
}

