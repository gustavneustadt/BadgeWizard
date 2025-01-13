//
//  LEDPreviewView+asd.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//

extension LEDPreviewView {
    internal func displayLaser(_ buffer: inout [[Bool]]) {
        let frameSteps = 44 * 3  // LED_COLS * 3 for in-still-out
        let currentStep = Int(currentPosition) % frameSteps
        let maxWidth = pixels[0].count
        let badgeWidth = 44
        
        // Calculate centering offset
        let offset = (badgeWidth - maxWidth) / 2
        
        if currentStep < 44 {  // Laser in
            let c = min(currentStep, badgeWidth - 1)
            for y in 0..<11 {
                for x in 0..<44 {
                    let sourceX = x - offset
                    if x < currentStep {
                        buffer[y][x] = sourceX >= 0 && sourceX < maxWidth ? pixels[y][sourceX].isOn : false
                    } else {
                        let laserX = c - offset
                        buffer[y][x] = laserX >= 0 && laserX < maxWidth ? pixels[y][laserX].isOn : false
                    }
                }
            }
        } else if currentStep < 88 {  // Still
            displayFixed(&buffer)
        } else {  // Laser out
            let c = min(currentStep - 88, badgeWidth - 1)
            for y in 0..<11 {
                for x in 0..<44 {
                    let sourceX = x - offset
                    if x < c {
                        let laserX = c - offset
                        buffer[y][x] = laserX >= 0 && laserX < maxWidth ? pixels[y][laserX].isOn : false
                    } else {
                        buffer[y][x] = sourceX >= 0 && sourceX < maxWidth ? pixels[y][sourceX].isOn : false
                    }
                }
            }
        }
    }
}
