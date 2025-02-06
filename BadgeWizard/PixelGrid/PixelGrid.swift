import SwiftUI
import SwiftData

@Model
final class PixelGrid {
    
    @Attribute(.unique) var id: UUID
    
    // MARK: Properties
    var pixels: [[Bool]]
    var width: Int
    var height: Int
    
    weak var message: Message?
    
    init(pixels: [[Bool]] = [], width: Int? = nil, message: Message?) {
        let setWidth = width ?? 20
        let setHeight = 11
        
        self.height = setHeight
        self.width = setWidth
        self.message = message
        self.id = .init()
        guard pixels.isEmpty else {
            self.pixels = pixels
            return
        }
        self.pixels = Array(repeating: Array(repeating: false, count: setWidth), count: setHeight)
        
    }
    
    
    func buildMatrix() {
        let oldPixels = pixels
        let oldWidth = oldPixels.isEmpty ? 1 : oldPixels[0].count
        
        // Create array of the correct size
        var newPixels = Array(repeating: Array(repeating: false, count: width), count: height)
        
        DispatchQueue.concurrentPerform(iterations: height) { y in
            for x in 0..<width {
                if x < oldWidth && !oldPixels.isEmpty {
                    newPixels[y][x] = true
                } else {
                    newPixels[y][x] = false
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
        guard let message = self.message else { return }
        message.pixelGrids.removeAll { $0 === self }
        if message.pixelGrids.count < 1 {
            message.addGrid()
        }
    }
    
    func deleteGrid() {
        guard let message = self.message else { return }
        
        guard message.store?.selectedGridId == self.id else {
            self.deleteGridFromMessage()
            return
            
        }
        
        if let indexBefore = message.pixelGrids.firstIndex(where: { grid in
            grid == self
        })?.advanced(by: -1) {
            guard indexBefore >= 0 else {
                
                message.store?.selectedGridId = nil
                self.deleteGridFromMessage()
                return
            }
            
            message.store?.selectedGridId = message.pixelGrids[indexBefore].id
            self.deleteGridFromMessage()
            return
        }
        message.store?.selectedGridId = nil
        
        self.deleteGridFromMessage()
    }
    
    func reorder(direction: MoveDirection) {
        guard let message = self.message else { return }
        message.reorderGrid(id: self.id, direction: direction)
    }
    
    func isAt(position: GridPosition) -> Bool {
        guard let message = self.message else { return false }
        return message.isGridAt(id: self.id, position: position)
    }
}


