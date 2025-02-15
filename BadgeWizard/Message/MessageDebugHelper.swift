//
//  MessageDebugHelper.swift
//  BadgeWizard
//
//  Created by Gustav on 27.01.25.
//

import SwiftUI
import Foundation

extension Message {
    /// Exports the current message state as Swift code that can be used in debug builds
    func exportAsDebugCode(name: String = "testMessage") -> String {
        // Get the string representation of the enum cases
        let speedCase = String(describing: speed).components(separatedBy: ".").last ?? "medium"
        let modeCase = String(describing: mode).components(separatedBy: ".").last ?? "left"
        
        var code = """
        #if DEBUG
        extension Message {
            static var \(name): Message {
                var pixelGrids: [PixelGrid] = []
        """
        
        // Generate code for each grid
        for (index, grid) in pixelGrids.enumerated() {
            let asciiArt = grid.getAsciiArt()
            // Split into lines and add proper indentation
            let indentedArt = asciiArt.components(separatedBy: "\n")
                .map { "                    " + $0 }
                .joined(separator: "\n")
            
            code += """
            
                    // Grid \(index)
                    pixelGrids.append(
                        try! PixelGrid.fromASCIIArt(\"\"\"
            \(indentedArt)
                    \"\"\")
                    )
            """
        }
        
        code += """
        
        
                    let message = Message(
                        flash: \(flash),
                        marquee: \(marquee),
                        speed: .\(speedCase),
                        mode: .\(modeCase),
                        grids: pixelGrids
                    )
        
                    return message
                }
            }
            #endif
        """
        
        return code
    }
}

#if DEBUG
// Add a UI button or menu item to trigger export
extension Message {
    func copyDebugCodeToClipboard(name: String = "testMessage") {
        let code = exportAsDebugCode(name: name)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
    }
}
#endif
