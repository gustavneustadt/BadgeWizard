import SwiftUI

class PixelGrid: ObservableObject, Identifiable {
    var id: Identifier<PixelGrid> = .init()
    
    @Published var pixels: [[Pixel]]
    @Published var width: Int {
        willSet {
            message.objectWillChange.send()
        }
        didSet {
            buildMatrix()
        }
    }

    let height = 11
    
    unowned var message: Message
    
    init(pixels: [[Pixel]] = [], width: Int? = nil, message: Message) {
        self.width = width ?? 20
        self.pixels = pixels
        self.message = message
        
        guard pixels.isEmpty else { return }
        for y in 0..<height {
            var row: [Pixel] = []
            for x in 0..<self.width {
                row.append(Pixel(x: x, y: y, isOn: false))
            }
            self.pixels.append(row)
        }
        
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
        PixelGrid(pixels: self.pixels, width: self.width, message: self.message)
    }
    
    static func placeholder() -> PixelGrid {
        PixelGrid(message: Message.placeholder())
    }
    
    private func deleteGridFromMessage() {
        self.message.pixelGrids.removeAll { $0 === self }
        if self.message.pixelGrids.count < 1 {
            message.addGrid()
        }
    }
    
    func deleteGrid() {
        guard self.message.store?.selectedGridId == self.id else {
            self.deleteGridFromMessage()
            return
            
        }
        
        if let indexBefore = self.message.pixelGrids.firstIndex(where: { grid in
            grid == self
        })?.advanced(by: -1) {
            guard indexBefore >= 0 else {
                
                self.message.store?.selectedGridId = nil
                self.deleteGridFromMessage()
                return
            }
            
            self.message.store?.selectedGridId = self.message.pixelGrids[indexBefore].id
            self.deleteGridFromMessage()
            return
        }
        self.message.store?.selectedGridId = nil
        
        self.deleteGridFromMessage()
    }
}


