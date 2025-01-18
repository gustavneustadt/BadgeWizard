//
//  PixelGrid+Manipulation.swift
//  BadgeWizard
//
//  Created by Gustav on 18.01.25.
//
import Foundation

extension PixelGrid {
    func setPixel(x: Int, y: Int, isOn: Bool, undoManager: UndoManager?) {
        guard pixels[y][x].isOn != isOn else { return }
        
        var newPixels = pixels
        newPixels[y][x] = Pixel(x: x, y: y, isOn: isOn)
        pixels = newPixels
        
        undoManager?.registerUndo(withTarget: self) { grid in
            grid.setPixel(x: x, y: y, isOn: !isOn, undoManager: undoManager)
        }
    }
    
    func erase(undoManager: UndoManager?) {
        
        let previousState = pixels
        undoManager?.registerUndo(withTarget: self) { grid in
            grid.restoreState(previousState, undoManager: undoManager)
        }
        
        var newPixels = pixels
        for y in 0..<height {
            for x in 0..<width {
                newPixels[y][x] = Pixel(x: x, y: y, isOn: false)
            }
        }
        
        pixels = newPixels
        
    }
    
    /// Helper function to restore state from given Pixels
    private func restoreState(_ state: [[Pixel]], undoManager: UndoManager?) {
        // Store the current state for redo
        let previousState = pixels
        
        // Register the redo action
        undoManager?.registerUndo(withTarget: self) { grid in
            grid.restoreState(previousState, undoManager: undoManager)
        }
        
        // Restore the state
        pixels = state
    }
    
    func invertPixels(undoManager: UndoManager?) {
        // Create a new matrix with inverted values
        var newPixels = Array(repeating: Array(repeating: Pixel(x: 0, y: 0, isOn: false), count: width), count: height)
        
        // Perform the inversion operation concurrently for better performance
        DispatchQueue.concurrentPerform(iterations: height) { y in
            for x in 0..<width {
                // Create a new pixel with inverted isOn state
                newPixels[y][x] = Pixel(
                    x: x,
                    y: y,
                    isOn: !pixels[y][x].isOn
                )
            }
        }
        
        undoManager?.registerUndo(withTarget: self) { grid in
            grid.invertPixels(undoManager: undoManager)
        }
        
        // Update the pixels array with the inverted values
        pixels = newPixels
    }
}
