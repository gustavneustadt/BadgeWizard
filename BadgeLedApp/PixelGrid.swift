import SwiftUI

struct Pixel: Identifiable, Hashable, Equatable {
    let id = UUID()
    var x: Int
    var y: Int
    var isOn: Bool
    
    mutating func set(_ state: Bool) {
        self.isOn = state
    }
}

class PixelGrid: ObservableObject, Identifiable, Equatable {
    static func == (lhs: PixelGrid, rhs: PixelGrid) -> Bool {
        // Compare the relevant properties
        return lhs.pixels == rhs.pixels &&
        lhs.width == rhs.width &&
        lhs.height == rhs.height &&
        lhs.patternGap == rhs.patternGap
    }
    
    @Published var pixels: [[Pixel]] {
        willSet {
            parent.objectWillChange.send()
        }
    }
    @Published var width = 20 {
        willSet {
            parent.objectWillChange.send()
        }
        didSet {
            buildMatrix()
        }
    }
    
    unowned var parent: GridState
    
    let height = 11
    
    // Add the gap property here
    @Published var patternGap: Int = 1
    
    init(parent: GridState) {
        self.parent = parent
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


