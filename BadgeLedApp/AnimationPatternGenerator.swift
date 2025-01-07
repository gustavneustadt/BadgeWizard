//
//  AnimationPatternGenerator.swift
//  BadgeLedApp
//
//  Created by Gustav on 07.01.25.
//
import Foundation

class AnimationPatternGenerator {
    static func createMovingCircle() -> [[Pixel]] {
        let height = 11
        let frameWidth = 44
        let frames = 8  // Number of distinct positions
        let totalWidth = frameWidth * frames
        var pixels: [[Pixel]] = []
        
        // Initialize empty grid
        for y in 0..<height {
            var row: [Pixel] = []
            for x in 0..<totalWidth {
                row.append(Pixel(x: x, y: y, isOn: false))
            }
            pixels.append(row)
        }
        
        // Create the moving circle pattern
        for frame in 0..<frames {
            let isMovingRight = frame < frames/2
            let position = if isMovingRight {
                frame * (frameWidth / (frames/2 - 1))
            } else {
                (frames - 1 - frame) * (frameWidth / (frames/2 - 1))
            }
            
            let centerX = (frame * frameWidth) + Int(position)
            let centerY = 5  // Vertical center
            let radius = 3   // Circle radius
            
            // Draw circle in current frame position
            for y in 0..<height {
                for x in (frame * frameWidth)..<((frame + 1) * frameWidth) {
                    let dx = Double(x - centerX)
                    let dy = Double(y - centerY)
                    let distance = sqrt(dx * dx + dy * dy)
                    pixels[y][x].isOn = distance <= Double(radius)
                }
            }
        }
        
        return pixels
    }
}
