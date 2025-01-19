//
//  Message.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import Foundation

// Swift equivalent of the Flutter code
class Message: ObservableObject, Identifiable, Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: Identifier<Message> = .init()
    @Published var pixelGrids: [PixelGrid] = []
    @Published var flash: Bool
    @Published var marquee: Bool
    @Published var speed: Speed
    @Published var mode: Mode
    
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
    
    func addGrid() {
        let lastPixelGrid = pixelGrids.last?.duplicate()
        
        let newPixelGrid = lastPixelGrid ?? .init(width: lastPixelGrid?.width, message: self)
        
        pixelGrids.append(newPixelGrid)
        store?.selectedGridId = newPixelGrid.id
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
