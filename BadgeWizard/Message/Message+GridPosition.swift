//
//  Message+GridPosition.swift
//  BadgeWizard
//
//  Created by Gustav on 19.01.25.
//

import Foundation

extension Message {
    enum GridPosition {
        case start
        case end
        case middle
    }
    
    /// Determines if a grid is at the start, end, or middle of the pixelGrids array
    /// - Parameter id: The Identifier of the PixelGrid to check
    /// - Returns: A GridPosition indicating where in the array the grid is located
    func getGridPosition(id: Identifier<PixelGrid>) -> GridPosition {
        guard let index = pixelGrids.firstIndex(where: { $0.id == id }) else {
            return .middle // Return middle if grid not found to maintain function type
        }
        
        if index == 0 {
            return .start
        } else if index == pixelGrids.count - 1 {
            return .end
        }
        
        return .middle
    }
    
    /// Checks if a grid is at either the start or end of the pixelGrids array
    /// - Parameters:
    ///   - id: The Identifier of the PixelGrid to check
    ///   - position: The position to check for (start or end)
    /// - Returns: true if the grid is at the specified position
    func isGridAt(id: Identifier<PixelGrid>, position: GridPosition) -> Bool {
        if pixelGrids.count == 1 {
            return position == .start || position == .end
        }
        
        return getGridPosition(id: id) == position
    }
}
