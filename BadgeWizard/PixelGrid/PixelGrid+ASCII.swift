//
//  PixelGrid+ASCII.swift
//  BadgeWizard
//
//  Created by Gustav on 27.01.25.
//
import Foundation

extension PixelGrid {
    enum ASCIIArtError: Error {
        case invalidHeight(Int)
        case inconsistentWidth
        case emptyInput
    }
    
    /// Creates a PixelGrid from an ASCII art string representation
    /// ASCII art should use any non-whitespace character for "on" pixels and spaces or hyphens for "off" pixels
    /// - Parameters:
    ///   - asciiArt: The ASCII art string to parse
    ///   - undoManager: Optional UndoManager for undo/redo support
    /// - Throws: ASCIIArtError if the input is invalid
    func loadFromASCIIArt(_ asciiArt: String, undoManager: UndoManager?) throws {
        // Split into rows and filter out empty lines
        let rows = asciiArt.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // Validation checks
        guard !rows.isEmpty else {
            throw ASCIIArtError.emptyInput
        }
        
        guard rows.count <= height else {
            throw ASCIIArtError.invalidHeight(rows.count)
        }
        
        let rowWidth = rows[0].count
        guard rows.allSatisfy({ $0.count == rowWidth }) else {
            throw ASCIIArtError.inconsistentWidth
        }
        
        // Store current state for undo
        let previousState = pixels
        
        // Update grid width to match ASCII art
        width = rowWidth
        
        // Create new pixel grid
        var newPixels = Array(repeating: Array(repeating: false, count: width), count: height)
        
        // Parse ASCII art into pixels
        for (y, row) in rows.enumerated() {
            for (x, char) in row.enumerated() {
                // Consider any non-space, non-hyphen character as an "on" pixel
                let isOn = char != " " && char != "-"
                newPixels[y][x] = isOn
            }
        }
        
        // Fill remaining rows with empty pixels if ASCII art is shorter than grid height
        for y in rows.count..<height {
            for x in 0..<width {
                newPixels[y][x] = false
            }
        }
        
        // Register undo action
        undoManager?.registerUndo(withTarget: self) { grid in
            grid.restoreState(previousState, undoManager: undoManager)
        }
        undoManager?.setActionName("Load ASCII Art")
        
        // Update pixels
        pixels = newPixels
    }
    
    /// Convenience method that returns a new PixelGrid initialized from ASCII art
    /// - Parameters:
    ///   - asciiArt: The ASCII art string to parse
    ///   - message: The Message instance this grid belongs to
    /// - Returns: A new PixelGrid instance
    static func fromASCIIArt(_ asciiArt: String, message: Message) throws -> PixelGrid {
        let rows = asciiArt.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard !rows.isEmpty else {
            throw ASCIIArtError.emptyInput
        }
        
        let width = rows[0].count
        let grid = PixelGrid(width: width, message: message)
        try grid.loadFromASCIIArt(asciiArt, undoManager: nil)
        return grid
    }
    
    
    func getAsciiArt() -> String {
        var result = ""
        var lastRow = 0
        for (i, row) in self.pixels.enumerated() {
            if lastRow != i {
                result.append("\n")
                lastRow = i
            }
            for pixel in row {
                if pixel == true {
                    result.append("0")
                } else {
                    result.append("-")
                }
            }
        }
        return result
    }
}
