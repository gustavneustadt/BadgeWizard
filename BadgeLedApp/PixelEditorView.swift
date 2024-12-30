//
//  PixelEditorView 2.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//
import SwiftUI

struct PixelEditorView: View {
    @ObservedObject var viewModel: PixelGridViewModel
    @State private var drawMode: Bool = true
    @Environment(\.undoManager) var undo
    
    var body: some View {
        PixelGridImage(width: viewModel.width, pixels: viewModel.pixels)
            .frame(width: CGFloat(viewModel.width * 20),
                   height: CGFloat(11 * 20))
            .padding()
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let pixelSize: CGFloat = 20// 20px + 1px spacing
                        let padding: CGFloat = 15 // padding value
                        
                        let x = Int((value.location.x - padding) / pixelSize)
                        let y = Int((value.location.y - padding) / pixelSize)
                        
                        if x >= 0 && x < viewModel.width && y >= 0 && y < viewModel.height {
                            if value.translation == .zero {
                                // This is the start of the drag - set mode based on initial pixel
                                drawMode = !viewModel.pixels[y][x].isOn
                            }
                            viewModel.setPixel(x: x, y: y, isOn: drawMode, undoManager: undo)
                        }
                    }
            )
    }
}
