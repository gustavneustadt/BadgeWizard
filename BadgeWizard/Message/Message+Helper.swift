//
//  Message+Helper.swift
//  BadgeLedApp
//
//  Created by Gustav on 31.12.24.
//

import Foundation

extension Message {
    static func pixelsToHexStrings(pixels: [[Bool]]) -> [String] {
        let height = pixels.count
        let width = pixels.first?.count ?? 0
        
        func chunkToHex(startX: Int) -> String {
            var hexString = ""
            var bytes: [UInt8] = Array(repeating: 0, count: height)
            
            for y in 0..<height {
                // Process 8 pixels in this row starting from startX
                for x in 0..<8 {
                    let actualX = startX + x
                    if actualX < width && pixels[y][actualX] == true {
                        // For 90-degree counterclockwise rotation:
                        // - The x position becomes the bit position (y in the output)
                        // - The y position becomes the byte index from right to left
                        bytes[y] |= (1 << (7 - x))
                    }
                }
            }
            
            // Convert bytes to hex
            for byte in bytes {
                hexString += String(format: "%02X", byte)
            }
            
            return hexString
        }
        
        var hexStrings: [String] = []
        
        // Process the grid in chunks of 8 pixels wide
        for startX in stride(from: 0, to: width, by: 8) {
            let chunk = chunkToHex(startX: startX)
            hexStrings.append(chunk)
        }
        
        return hexStrings
    }
    
    
    static func combinePixelArrays(_ arrays: [[[Bool]]]) -> [[Bool]] {
        print("Called combinePixelArrays")
        guard !arrays.isEmpty else { return [] }
        
        let height = arrays[0].count // All arrays should have same height
        var combined: [[Bool]] = Array(repeating: [], count: height)
        
        // For each row
        for y in 0..<height {
            // Go through each array and append its pixels for this row
            for pixelArray in arrays {
                combined[y].append(contentsOf: pixelArray[y])
            }
        }
        
        return combined
    }
    
    static func createPadding(width: Int) -> [[Bool]] {
        let height = 11
        return (0..<height).map { y in
            (0..<width).map { x in
                false
            }
        }
    }
}
