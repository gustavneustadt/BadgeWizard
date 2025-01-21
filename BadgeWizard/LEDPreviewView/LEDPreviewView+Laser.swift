//
//  LEDPreviewView+asd.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//

extension LEDPreviewView {
    internal func displayLaser() {
        let frameSteps = 44 * 3  // LED_COLS * 3 for in-still-out
        let currentStep = Int(currentPosition) % frameSteps
        let maxWidth = pixels[0].count
        let badgeWidth = 44
        
        // Calculate centering offset
        let offset = (badgeWidth - maxWidth) / 2
        
        displayBuffer.clear()
        
        if currentStep < 44 {  // Laser in
            let c = min(currentStep, badgeWidth - 1)
            for y in 0..<11 {
                for x in 0..<44 {
                    let sourceX = x - offset
                    if x < currentStep {
                        if sourceX >= 0 && sourceX < maxWidth {
                            displayBuffer.set(x, y, pixels[y][sourceX].isOn)
                        }
                    } else {
                        let laserX = c - offset
                        if laserX >= 0 && laserX < maxWidth {
                            displayBuffer.set(x, y, pixels[y][laserX].isOn)
                        }
                    }
                }
            }
        } else if currentStep < 88 {  // Still
            displayFixed()
        } else {  // Laser out
            let c = min(currentStep - 88, badgeWidth - 1)
            for y in 0..<11 {
                for x in 0..<44 {
                    let sourceX = x - offset
                    if x < c {
                        let laserX = c - offset
                        if laserX >= 0 && laserX < maxWidth {
                            displayBuffer.set(x, y, pixels[y][laserX].isOn)
                        }
                    } else {
                        if sourceX >= 0 && sourceX < maxWidth {
                            displayBuffer.set(x, y, pixels[y][sourceX].isOn)
                        }
                    }
                }
            }
        }
    }
}
