//
//  PixelEditorView 2.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//
import SwiftUI

struct PixelEditorView: View {
    @ObservedObject var model: PixelGrid
    @State private var drawMode: Bool = true
    @Environment(\.undoManager) var undo
    
    var body: some View {
        VStack {
            PixelGridImage(width: model.width, pixels: model.pixels)
                .frame(width: CGFloat(model.width * 20),
                       height: CGFloat(11 * 20))
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let pixelSize: CGFloat = 20 // 20px + 1px spacing
                            
                            let x = Int(value.location.x / pixelSize)
                            let y = Int(value.location.y / pixelSize)
                            
                            if x >= 0 && x < model.width && y >= 0 && y < model.height {
                                if value.translation == .zero {
                                    // This is the start of the drag - set mode based on initial pixel
                                    drawMode = !model.pixels[y][x].isOn
                                }
                                model.setPixel(x: x, y: y, isOn: drawMode, undoManager: undo)
                            }
                        }
                )
            
        }
    }
}
