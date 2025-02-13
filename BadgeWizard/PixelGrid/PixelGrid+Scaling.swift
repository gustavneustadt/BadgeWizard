import SwiftUI

extension PixelGrid {
    /// Resizes the grid from the trailing edge while preserving pixels at the leading edge.
    /// This function maintains pixel data at the left edge of the grid while allowing expansion
    /// or contraction from the right edge. When expanding, it can restore previously cached pixels.
    ///
    /// - Parameters:
    ///   - newWidth: The target width for the grid after resizing. Must be greater than 0.
    ///   - cache: Optional array of cached pixels to restore from when expanding the grid.
    ///            The cache should contain the pixels from a previous state of the grid.
    ///            If provided, pixels beyond the original width will be restored from this cache
    ///            instead of being initialized as empty (false).
    ///   - undoManager: The UndoManager instance to register undo/redo operations with.
    ///                  If provided, the resize operation can be undone/redone.
    ///                  
    func resizeFromTrailingEdge(to newWidth: Int, cache: [[Bool]]? = nil, undoManager: UndoManager?) {
        // Early exit if no size change is needed
        guard newWidth != self.width else { return }
        
        // Store current state for undo operation
        let oldWidth = pixels[0].count
        let oldPixels = pixels
        
        // Register undo/redo operations
        undoManager?.registerUndo(withTarget: self) { grid in
            // Restore the previous state when undoing
            grid.update(pixels: oldPixels, width: oldWidth)
            
            // Register redo operation
            undoManager?.registerUndo(withTarget: grid) { grid in
                grid.resizeFromTrailingEdge(to: newWidth, cache: cache, undoManager: undoManager)
            }
        }
        undoManager?.setActionName("Resize Grid")
        
        // Initialize new pixel array with target dimensions
        var newPixels = Array(repeating: Array(repeating: false, count: newWidth), count: height)
        
        // Process each row concurrently for better performance
        DispatchQueue.concurrentPerform(iterations: height) { y in
            for x in 0..<newWidth {
                if newWidth > oldWidth && x >= oldWidth,
                    let cache = cache,
                    x < cache[0].count {
                    // When expanding, restore pixels from cache if available
                    newPixels[y][x] = cache[y][x]
                } else if x < oldWidth {
                    // Preserve existing pixels from the leading edge
                    newPixels[y][x] = pixels[y][x]
                }
                // New pixels beyond cache width remain false (empty)
            }
        }
        
        // Update the grid with the new pixels
        self.update(pixels: newPixels, width: newWidth)
    }
}
