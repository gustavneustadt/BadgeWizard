//
//  PixelGrid+Manipulation.swift
//  BadgeWizard
//
//  Created by Gustav on 18.01.25.
//
import Foundation

extension PixelGrid {
    func setPixel(x: Int, y: Int, isOn: Bool, isUndo: Bool = false, undoManager: UndoManager?) {
        guard pixels[y][x] != isOn else { return }
        guard let message = message else { return }
        guard let index = getArrayIndex() else { return }
        
        var newPixels = pixels
        newPixels[y][x] = isOn
        
        undoManager?.registerUndo(withTarget: message) { message in
            message.pixelGrids[index].setPixel(x: x, y: y, isOn: !isOn, isUndo: true, undoManager: undoManager)
        }
        undoManager?.setActionName("\(isOn ? isUndo ? "Disable" : "Enable" : isUndo ? "Enable" : "Disable") Pixel")
        
        message.pixelGrids[index].pixels = newPixels
    }
    
    func clear(undoManager: UndoManager?) {
        guard let message = message else { return }
        guard let index = getArrayIndex() else { return }
        
        let previousState = pixels
        undoManager?.registerUndo(withTarget: message) { message in
            message.pixelGrids[index].restoreState(previousState, undoManager: undoManager)
        }
        
        undoManager?.setActionName("Clear Grid")
        
        var newPixels = pixels
        for y in 0..<height {
            for x in 0..<width {
                newPixels[y][x] = false
            }
        }
        
        message.pixelGrids[index].pixels = newPixels
    }
    
    /// Helper function to restore state from given Pixels
    func restoreState(_ state: [[Bool]], undoManager: UndoManager?) {
        guard let message = message else { return }
        guard let index = getArrayIndex() else { return }
        
        // Store the current state for redo
        let previousState = pixels
        
        // Register the redo action
        undoManager?.registerUndo(withTarget: message) { message in
            message.pixelGrids[index].restoreState(previousState, undoManager: undoManager)
        }
        
        undoManager?.setActionName("Restore Grid")
        
        // Restore the state
        message.pixelGrids[index].pixels = state
    }
    
    func invert(undoManager: UndoManager?) {
        guard let message = message else { return }
        guard let index = getArrayIndex() else { return }
        
        
        // Create a new matrix with inverted values
        var newPixels = Array(repeating: Array(repeating: false, count: width), count: height)
        
        // Perform the inversion operation concurrently for better performance
        DispatchQueue.concurrentPerform(iterations: height) { y in
            for x in 0..<width {
                // Create a new pixel with inverted isOn state
                newPixels[y][x] = !pixels[y][x]
            }
        }
        
        undoManager?.registerUndo(withTarget: message) { message in
            message.pixelGrids[index].invert(undoManager: undoManager)
        }
        
        undoManager?.setActionName("Invert Grid")
        
        // Update the pixels array with the inverted values
        message.pixelGrids[index].pixels = newPixels
    }
}
