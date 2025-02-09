import SwiftUI

extension PixelGrid {
    /// Resizes the grid from the trailing edge while preserving pixels at the leading edge
    /// - Parameters:
    ///   - newWidth: The desired new width for the grid
    ///   - cache: Optional cache grid to restore pixels from when expanding
    ///   - undoManager: UndoManager for undo/redo support
    func resizeFromTrailingEdge(to newWidth: Int, cache: PixelGrid? = nil, undoManager: UndoManager?) {
        guard let message = self.message else { return }
        guard let index = self.getArrayIndex() else { return }
        
        guard newWidth != self.width else { return }
        
        let oldWidth = pixels[0].count
        let oldPixels = pixels // Store current state for undo
        
        // Register undo action with the old state
        undoManager?.registerUndo(withTarget: message) { message in
            // Restore the previous state
            message.pixelGrids[index].update(pixels: oldPixels, width: oldWidth)
            
            // Register redo
            undoManager?.registerUndo(withTarget: message) { message in
                message.pixelGrids[index].resizeFromTrailingEdge(to: newWidth, cache: cache, undoManager: undoManager)
            }
        }
        undoManager?.setActionName("Resize Grid")
        
        // Create array of the correct size
        var newPixels = Array(repeating: Array(repeating: false, count: newWidth), count: height)
        
        // Process each row concurrently for better performance
        DispatchQueue.concurrentPerform(iterations: height) { y in
            for x in 0..<newWidth {
                if newWidth > oldWidth && x >= oldWidth, let cache = cache, x < cache.width {
                    // If we're expanding and have a cache, use cached pixels
                    newPixels[y][x] = cache.pixels[y][x]
                } else if x < oldWidth {
                    // Copy existing pixels from the start
                    newPixels[y][x] = pixels[y][x]
                }
                // New pixels beyond cache width remain false
            }
        }
        
        self.update(pixels: newPixels, width: newWidth)
    }
}
