import SwiftUI

struct Pixel: Identifiable, Hashable {
    let id = UUID()
    var x: Int
    var y: Int
    var isOn: Bool
    
    mutating func set(_ state: Bool) {
        self.isOn = state
    }
}

class PixelGridViewModel: ObservableObject {
    @Published var pixels: [[Pixel]]
    @Published var width = 44 {
        didSet {
            buildMatrix()
        }
    }
    let height = 11
    
    // Add the gap property here
    @Published var patternGap: Int = 1
    
    init() {
        pixels = []
        for y in 0..<height {
            var row: [Pixel] = []
            for x in 0..<width {
                row.append(Pixel(x: x, y: y, isOn: false))
            }
            pixels.append(row)
        }
    }
    
    func erase() {
        for row in 0..<pixels.count {
            for column in 0..<pixels[row].count {
                pixels[row][column].set(false)
            }
        }
    }
    
    func stringToPixelGrid(text: String) {
        // Split the string into rows
        let rows = text.components(separatedBy: "\n")
        
        // Create the pixel grid
        var pixelGrid: [[Pixel]] = []
        
        // Process each row
        for (y, row) in rows.enumerated() {
            var pixelRow: [Pixel] = []
            
            // Process each character in the row
            for (x, char) in row.enumerated() {
                let pixel = Pixel(
                    x: x,
                    y: y,
                    isOn: (char == "O")
                )
                pixelRow.append(pixel)
            }
            
            // Only append non-empty rows to handle any trailing newlines
            if !pixelRow.isEmpty {
                pixelGrid.append(pixelRow)
            }
        }
        width = pixelGrid.isEmpty ? 0 : pixelGrid[0].count
        pixels = pixelGrid
    }
    
    func buildMatrix() {
        let oldPixels = pixels
        let oldWidth = oldPixels.isEmpty ? 0 : oldPixels[0].count
        
        // Create new matrix with updated width
        var newPixels: [[Pixel]] = []
        for y in 0..<height {
            var row: [Pixel] = []
            for x in 0..<width {
                if x < oldWidth && !oldPixels.isEmpty {
                    // Preserve existing pixel state
                    row.append(Pixel(x: x, y: y, isOn: oldPixels[y][x].isOn))
                } else {
                    // Add new pixel with default state
                    row.append(Pixel(x: x, y: y, isOn: false))
                }
            }
            newPixels.append(row)
        }
        
        pixels = newPixels
    }
    
    func setPixel(x: Int, y: Int, isOn: Bool, undoManager: UndoManager?) {
        guard pixels[y][x].isOn != isOn else { return }
        
        pixels[y][x].isOn = isOn
        
        undoManager?.registerUndo(withTarget: self, handler: { _ in
            self.pixels[y][x].isOn = !isOn
        })
    }
    
    private func chunkToHex(startX: Int) -> String {
        var hexString = ""
        var bytes: [UInt8] = Array(repeating: 0, count: 11) // Changed to 11 to match height
        
        for y in 0..<height {
            // Process 8 pixels in this row starting from startX
            for x in 0..<8 {
                let actualX = startX + x
                if actualX < width && pixels[y][actualX].isOn {
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
    
    // Convert all pixels to an array of hex strings
    func toHexStrings() -> [String] {
        var hexStrings: [String] = []
        
        // Process the grid in chunks of 8 pixels wide
        for startX in stride(from: 0, to: width, by: 8) {
            let chunk = chunkToHex(startX: startX)
            hexStrings.append(chunk)
        }
        
        return hexStrings
    }
}

// ASCII Art Import Extension
extension PixelGridViewModel {
    func getAsciiArt() -> String {
        var result = ""
        var lastRow = 0
        for (i, row) in self.pixels.enumerated() {
            if lastRow != i {
                result.append("\n")
                lastRow = i
            }
            for pixel in row {
                if pixel.isOn {
                    result.append("0")
                } else {
                    result.append("-")
                }
            }
        }
        return result
    }
    
    private func parseAsciiArt(_ input: String) -> [[Bool]] {
        // Split into lines and remove empty lines
        let lines = input.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        // Convert to boolean grid and handle trailing empty items
        let boolGrid = lines.map { line -> [Bool] in
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            return trimmedLine.map { char in char == "0" }
        }
        
        return boolGrid
    }
    
    private func findFirstAvailablePosition(for pattern: [[Bool]]) -> (x: Int, y: Int) {
        // Always start at 0,0 since we'll adjust the grid if needed
        return (x: 0, y: 0)
    }
    
    private func ensureGridCapacity(for pattern: [[Bool]]) {
        let patternWidth = pattern[0].count
        
        // If pattern is wider than current grid, adjust the width
        if patternWidth > width {
            width = patternWidth
        }
    }
    
    private func placePattern(_ pattern: [[Bool]], at position: (x: Int, y: Int)) {
        for (y, row) in pattern.enumerated() {
            guard y < height else { break } // Don't exceed grid height
            
            for (x, isOn) in row.enumerated() {
                guard x < width else { break } // Don't exceed grid width
                
                if isOn {
                    pixels[position.y + y][position.x + x].isOn = true
                }
            }
        }
    }
    
    func importAsciiArt(_ input: String) {
        let pattern = parseAsciiArt(input)
        
        guard !pattern.isEmpty && !pattern[0].isEmpty else {
            print("Empty pattern")
            return
        }
        
        // Ensure grid can accommodate the pattern
        ensureGridCapacity(for: pattern)
        
        // Get starting position (always 0,0 in this implementation)
        let position = findFirstAvailablePosition(for: pattern)
        
        // Place the pattern
        placePattern(pattern, at: position)
    }
}


