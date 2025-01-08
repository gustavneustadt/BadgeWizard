//
//  PixelEditorView 2.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//
import SwiftUI

struct PixelGridView: View {
    @ObservedObject var pixelGrid: PixelGrid
    @State private var drawMode: Bool = true
    @Environment(\.undoManager) var undo
    
    var body: some View {
        VStack {
            PixelGridImage(pixelGrid: pixelGrid)
                .frame(width: CGFloat(pixelGrid.width * 20),
                       height: CGFloat(11 * 20))
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let pixelSize: CGFloat = 20 // 20px + 1px spacing
                            
                            let x = Int(value.location.x / pixelSize)
                            let y = Int(value.location.y / pixelSize)
                            
                            if x >= 0 && x < pixelGrid.width && y >= 0 && y < pixelGrid.height {
                                if value.translation == .zero {
                                    // This is the start of the drag - set mode based on initial pixel
                                    drawMode = !pixelGrid.pixels[y][x].isOn
                                }
                                pixelGrid.setPixel(x: x, y: y, isOn: drawMode, undoManager: undo)
                            }
                        }
                )
            
        }
    }
}
