//
//  Message.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import Foundation
import SwiftData

@Model
final class Message: Codable {

    // MARK: Relationship
    var pixelGrids: [PixelGrid] = []
    
    @Attribute(.ephemeral)
    var forcePixelUpdate: Bool = false
    
    func notifyPixelContentChanged() {
        forcePixelUpdate.toggle()
    }
    
    @Attribute(.unique) var id: UUID
    
    // MARK: Properties
    var flash: Bool
    var marquee: Bool
    var speed: Speed
    var mode: Mode
    var onionSkinning: Bool
    

    var width: Int {
        pixelGrids.reduce(0) { partialResult, grid in
            return partialResult + grid.width
        }
    }
    
    var selectedGridId: UUID? {
        get {
            pixelGrids.first { grid in
                grid.selected == true
            }?.id
        }
        set(id) {
            pixelGrids.first { grid in
                grid.id == id
            }?.selected = true
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
    
    enum CodingKeys: CodingKey {
        case id
        case pixelGrids
        case flash
        case marquee
        case speed
        case mode
        case onionSkinning
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(pixelGrids, forKey: .pixelGrids)
        try container.encode(flash, forKey: .flash)
        try container.encode(marquee, forKey: .marquee)
        try container.encode(speed, forKey: .speed)
        try container.encode(mode, forKey: .mode)
        try container.encode(onionSkinning, forKey: .onionSkinning)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        pixelGrids = try container.decode([PixelGrid].self, forKey: .pixelGrids)
        flash = try container.decode(Bool.self, forKey: .flash)
        marquee = try container.decode(Bool.self, forKey: .marquee)
        speed = try container.decode(Speed.self, forKey: .speed)
        mode = try container.decode(Mode.self, forKey: .mode)
        onionSkinning = try container.decode(Bool.self, forKey: .onionSkinning)
        store = nil // Will be set after decoding
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
            return
        }
        
        let newGrid = PixelGrid.init(
            width: grid?.width,
            message: self
        )
        
        pixelGrids.append(newGrid)

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
    
    func selectGrid(_ pixelGridId: UUID) {
        if let selectedGrid = pixelGrids.first(where: { grid in
            return grid.selected == true
        }) {
            
            if selectedGrid.id == pixelGridId {
                return
            }
            
            selectedGrid.selected = false
        }
        
        if let gridToSelect = pixelGrids.first(where: { grid in
            return grid.id == pixelGridId
        }) {
            gridToSelect.selected = true
        }
    }
    
    func getSelectedGrid() -> PixelGrid? {
        pixelGrids.first(where: { $0.id == selectedGridId })
    }
}
