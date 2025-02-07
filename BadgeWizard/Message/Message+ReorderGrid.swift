//
//  Message+ReorderGrid.swift
//  BadgeWizard
//
//  Created by Gustav on 19.01.25.
//

import Foundation
extension Message {
    
    @discardableResult
    func reorderGrid(_ id: UUID, toIndex: Int) -> Bool {
        // Validate the new index is within bounds
        guard toIndex >= 0 && toIndex <= pixelGrids.count else { return false }
        
        // Find the grid with the given id
        guard let currentIndex = pixelGrids.firstIndex(where: { $0.id == id }) else { return false }
        
        // Don't do anything if the index is the same
        guard currentIndex != toIndex else { return true }
        
        // Remove the grid from its current position
        let grid = pixelGrids.remove(at: currentIndex)
        
        // Insert it at the new position
        pixelGrids.insert(grid, at: toIndex)
        
        return true
    }
    
    @discardableResult
    func reorderGrid(id: UUID, direction: MoveDirection) -> Bool {
        guard let currentIndex = pixelGrids.firstIndex(where: { $0.id == id }) else { return false }
        
        let newIndex: Int
        switch direction {
        case .forward:
            // Can't move forward if already at the end
            guard currentIndex < pixelGrids.count - 1 else { return false }
            newIndex = currentIndex + 1
        case .backward:
            // Can't move backward if already at the start
            guard currentIndex > 0 else { return false }
            newIndex = currentIndex - 1
        }
        
        return reorderGrid(id, toIndex: newIndex)
    }
    
    
}
