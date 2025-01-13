import SwiftUI

class PixelGrid: ObservableObject, Identifiable {
    @Published var pixels: [[Pixel]]
    @Published var width: Int {
        didSet {
            buildMatrix()
        }
    }

    let height = 11
    
    // Add the gap property here
    @Published var patternGap: Int = 1
    
    init(pixels: [[Pixel]] = [], width: Int? = nil) {
        self.width = width ?? 20
        self.pixels = pixels
        
        guard pixels.isEmpty else { return }
        for y in 0..<height {
            var row: [Pixel] = []
            for x in 0..<self.width {
                row.append(Pixel(x: x, y: y, isOn: false))
            }
            self.pixels.append(row)
        }
    }
    
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
    
    func pixelFromString(text: String) {
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
                    isOn: (char == "0")
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
        let oldWidth = oldPixels.isEmpty ? 1 : oldPixels[0].count
        
        // Create array of the correct size
        var newPixels = Array(repeating: Array(repeating: Pixel(x: 0, y: 0, isOn: false), count: width), count: height)
        
        DispatchQueue.concurrentPerform(iterations: height) { y in
            for x in 0..<width {
                if x < oldWidth && !oldPixels.isEmpty {
                    newPixels[y][x] = Pixel(x: x, y: y, isOn: oldPixels[y][x].isOn)
                } else {
                    newPixels[y][x] = Pixel(x: x, y: y, isOn: false)
                }
            }
        }
        
        pixels = newPixels
    }
    
    
    
    func setPixel(x: Int, y: Int, isOn: Bool, undoManager: UndoManager?) {
        guard pixels[y][x].isOn != isOn else { return }
        
        var newPixels = pixels
        newPixels[y][x] = Pixel(x: x, y: y, isOn: isOn)
        pixels = newPixels
        
        undoManager?.registerUndo(withTarget: self) { grid in
            grid.setPixel(x: x, y: y, isOn: !isOn, undoManager: undoManager)
        }
        
    }
    
    func erase() {
        var newPixels = pixels
        for y in 0..<height {
            for x in 0..<width {
                newPixels[y][x] = Pixel(x: x, y: y, isOn: false)
            }
        }
        pixels = newPixels
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
    
    func duplicate() -> PixelGrid {
        PixelGrid(pixels: self.pixels, width: self.width)
    }
}


