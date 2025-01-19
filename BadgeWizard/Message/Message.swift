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
        let pixels = pixelGrids.map { grid in
            if self.mode == .picture {
                return Message.combinePixelArrays(
                    [
                        grid.pixels,
                        Message.createPadding(width: 4)
                    ]
                )
            }
            return grid.pixels
        }
        let combinedPixel = Message.combinePixelArrays(pixels)
        return Message.pixelsToHexStrings(pixels: combinedPixel)
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
    
    func getCombinedPixelArrays() -> [[Pixel]] {
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
