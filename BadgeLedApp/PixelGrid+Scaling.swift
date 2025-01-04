import SwiftUI

extension PixelGrid {
    /// Resizes the grid from the trailing edge while preserving pixels at the leading edge
    /// - Parameter newWidth: The desired new width for the grid
    func resizeFromTrailingEdge(to newWidth: Int) {
        let oldWidth = pixels[0].count
        let widthDifference = newWidth - oldWidth
        
        // If no change in width, return early
        guard widthDifference != 0 else { return }
        
        // Create array of the correct size
        var newPixels = Array(repeating: Array(repeating: Pixel(x: 0, y: 0, isOn: false), count: newWidth), count: height)
        
        // Process each row concurrently for better performance
        DispatchQueue.concurrentPerform(iterations: height) { y in
            for x in 0..<newWidth {
                if x < oldWidth && x < newWidth {
                    // Copy existing pixels from the start
                    newPixels[y][x] = Pixel(x: x, y: y, isOn: pixels[y][x].isOn)
                } else if x >= oldWidth {
                    // Add new empty pixels at the end
                    newPixels[y][x] = Pixel(x: x, y: y, isOn: false)
                }
            }
        }
        
        pixels = newPixels
        width = newWidth
    }
    
    
    /// Resizes the grid from the leading edge while preserving pixels at the trailing edge
    /// - Parameter newWidth: The desired new width for the grid
    func resizeFromLeadingEdge(to newWidth: Int) {
        let oldWidth = pixels[0].count
        let widthDifference = newWidth - oldWidth
        
        // If no change in width, return early
        guard widthDifference != 0 else { return }
        
        // Create array of the correct size
        var newPixels = Array(repeating: Array(repeating: Pixel(x: 0, y: 0, isOn: false), count: newWidth), count: height)
        
        // Process each row concurrently for better performance
        DispatchQueue.concurrentPerform(iterations: height) { y in
            for x in 0..<newWidth {
                if widthDifference > 0 {
                    // Growing the grid - add new empty pixels at the start
                    if x < widthDifference {
                        // New pixels at the start
                        newPixels[y][x] = Pixel(x: x, y: y, isOn: false)
                    } else {
                        // Copy existing pixels, shifted right
                        let oldX = x - widthDifference
                        newPixels[y][x] = Pixel(x: x, y: y, isOn: pixels[y][oldX].isOn)
                    }
                } else {
                    // Shrinking the grid - remove pixels from the start
                    let oldX = x - widthDifference
                    if oldX < oldWidth {
                        // Copy pixels from the right side
                        newPixels[y][x] = Pixel(x: x, y: y, isOn: pixels[y][oldX].isOn)
                    }
                }
            }
        }
        
        pixels = newPixels
        width = newWidth
    }
}
