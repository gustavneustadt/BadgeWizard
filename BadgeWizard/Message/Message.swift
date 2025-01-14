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
    
    init(flash: Bool, marquee: Bool, speed: Speed, mode: Mode) {
        self.flash = flash
        self.marquee = marquee
        self.speed = speed
        self.mode = mode
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
        
        pixelGrids.append(lastPixelGrid ?? .init(width: lastPixelGrid?.width, message: self))
    }
    
    func getCombinedPixelArrays() -> [[Pixel]] {
        Self.combinePixelArrays(
            pixelGrids.map {
                $0.pixels
            }
        )
    }
    
    static func placeholder () -> Message {
        Message(flash: false, marquee: false, speed: .medium, mode: .left)
    }
}
