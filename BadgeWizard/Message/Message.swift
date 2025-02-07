//
//  Message.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import Foundation
import SwiftData

@Model
final class Message {

    // MARK: Relationship
    var pixelGrids: [PixelGrid] = []
    
    @Attribute(.unique) var id: UUID
    
    // MARK: Properties
    var flash: Bool
    var marquee: Bool
    var speed: Speed
    var mode: Mode
    var onionSkinning: Bool
    
    
    @Transient
    var width: Int {
        pixelGrids.reduce(0) { partialResult, grid in
            return partialResult + grid.width
        }
    }
    
    @Transient
    unowned var store: MessageStore?
    
    init(
        flash: Bool = false,
        marquee: Bool = false,
        speed: Speed = .medium,
        mode: Mode = .left,
        store: MessageStore? = nil,
        grids: [PixelGrid] = []
    ) {
        self.flash = flash
        self.marquee = marquee
        self.speed = speed
        self.mode = mode
        self.id = .init()
        self.store = store
        self.onionSkinning = false
        
        if grids.isEmpty == false {
            addGrids(grids)
        } else {
            newGrid()
        }
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
    
    func addGrids(_ grids: [PixelGrid]) {
        for grid in grids {
            self.addGrid(grid)
        }
    }
    func addGrid(_ grid: PixelGrid) {
        let newGrid = PixelGrid(pixels: grid.pixels, width: grid.width, message: self)
        self.pixelGrids.append(newGrid)
    }
    
    func newGrid(_ grid: PixelGrid? = nil, duplicateGrid: Bool = false) {
        // FIXME: Something is up when duplicating a grid and then hitting delete
        if duplicateGrid,
        let newGrid = grid?.duplicate() {
            pixelGrids.append(newGrid)
            store?.selectedGridId = newGrid.id
            return
        }
        
        let newGrid = PixelGrid.init(
            width: grid?.width,
            message: self
        )
        
        pixelGrids.append(newGrid)
        store?.selectedGridId = newGrid.id
    }
    
    var combinedPixelArrays: [[Bool]] {
        getCombinedPixelArrays()
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
