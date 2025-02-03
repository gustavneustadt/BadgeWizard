//
//  Message.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import Foundation

// Swift equivalent of the Flutter code
class Message: ObservableObject, Identifiable, Equatable, Hashable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: Identifier<Message> = .init()
    
    // MARK: Message Badge Data
    @Published var pixelGrids: [PixelGrid] = []
    @Published var flash: Bool
    @Published var marquee: Bool
    @Published var speed: Speed
    @Published var mode: Mode
    
    
    // MARK: Other stuff
    @Published var onionSkinning: Bool = false
    unowned var store: MessageStore?
    
    var width: Int {
        pixelGrids.reduce(0) { partialResult, grid in
            return partialResult + grid.width
        }
    }
    
    init(flash: Bool = false, marquee: Bool = false, speed: Speed = .medium, mode: Mode = .left, store: MessageStore? = nil) {
        self.flash = flash
        self.marquee = marquee
        self.speed = speed
        self.mode = mode
        self.store = store
        addGrid()
    }
    
    func getBitmap() -> [String] {
        if mode == .animation {
            // First combine all pixel arrays
            let combinedPixels = Message.combinePixelArrays(pixelGrids.map(\.pixels))
            
            // Create result array with correct dimensions
            var result: [[Bool]] = Array(repeating: [], count: 11)
            
            // Process in chunks of 44
            for startIndex in stride(from: 0, to: combinedPixels[0].count, by: 44) {
                // Extract chunk
                let endIndex = min(startIndex + 44, combinedPixels[0].count)
                for y in 0..<11 {
                    // Add chunk
                    result[y].append(contentsOf: combinedPixels[y][startIndex..<endIndex])
                    // Add 4-pixel padding
                    result[y].append(contentsOf: Array(repeating: false, count: 4))
                }
            }
            
            return Message.pixelsToHexStrings(pixels: result)
        } else {
            let combinedPixels = Message.combinePixelArrays(pixelGrids.map(\.pixels))
            return Message.pixelsToHexStrings(pixels: combinedPixels)
        }
    }
    
    func addGrid(_ grid: PixelGrid? = nil, duplicateGrid: Bool = false) {
        // FIXME: Something is up when duplicating a grid and then hitting delete
        if duplicateGrid,
        let newGrid = grid?.duplicate() {
            pixelGrids.append(newGrid)
            store?.selectedGridId = newGrid.id
            return
        }
        
        let newGrid = PixelGrid.init(width: grid?.width, message: self)
        
        pixelGrids.append(newGrid)
        store?.selectedGridId = newGrid.id
    }
    
    func getCombinedPixelArrays() -> [[Bool]] {
        Self.combinePixelArrays(
            pixelGrids.map {
                $0.pixels
            }
        )
    }
    
    static func placeholder () -> Message {
        Message()
    }
}
