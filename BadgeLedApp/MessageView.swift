//
//  MessageView.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import SwiftUI
import SwiftUI

class GridState: ObservableObject {
    
    @Published var pixelGrids: [PixelGrid] = []
    init() {
        self.addGrid()
    }
    
    func addGrid() {
        let lastPixelGrid = pixelGrids.last?.duplicate()
        
        pixelGrids.append(lastPixelGrid ?? .init(parent: self, width: lastPixelGrid?.width))
    }
}

struct MessageView: View {
    @ObservedObject var message: Message
    @StateObject var gridState: GridState = .init()
    @State private var showingForm = false
    @State var scrollViewSize: CGSize = .zero
    
    var columnSum: Int {
        gridState.pixelGrids.reduce(0) { $0 + $1.width }
    }
    
    func updateMessageBitmap() {
        let pixels = gridState.pixelGrids.map({ grid in
            grid.pixels
        })
        let combinedPixel = Message.combinePixelArrays(pixels)
        let pixelHexStrings = Message.pixelsToHexStrings(pixels: combinedPixel)
        
        message.bitmap = pixelHexStrings
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .trailing) {
                ScrollView([.horizontal]) {
                    HStack(spacing: 2) {
                        HStack {
                            ForEach (gridState.pixelGrids) { grid in
                                GridView(pixelGrid: grid, onWidthChanged: { val in
                                    grid.width = val
                                }, onPixelChanged: updateMessageBitmap)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.background)
                        )
                        Button("Add", systemImage: "plus") {
                            gridState.addGrid()
                        }
                        .controlSize(.large)
                        Spacer()
                    }
                    .padding(.trailing, 300)
                    .frame(minWidth: scrollViewSize.width * 2)
                    .padding(.horizontal)
                    .padding(.vertical, 32)
                }
                .getSize($scrollViewSize)
                HStack {
                    HStack {
                        Spacer()
                        VStack {
                            Text("\(columnSum) Columns in Total")
                                .monospaced()
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                            Spacer()
                        }
                        Spacer()
                    }
                    HStack {
                        Divider()
                        MessageFormView(
                            mode: $message.mode,
                            marquee: $message.marquee,
                            flash: $message.flash,
                            speed: $message.speed
                        )
                        // MessageFormView(
                        //     updatePixels: { pixels, width in
                        //                 pixelGrid.pixels = pixels
                        //                 pixelGrid.width = width
                        //             },
                        //     erasePixels: pixelGrid.erase,
                        //     getAsciiArt: pixelGrid.getAsciiArt,
                        //     mode: $message.mode,
                        //     marquee: $message.marquee,
                        //     flash: $message.flash,
                        //     speed: $message.speed
                        // )
                    }
                    .onChange(of: gridState.pixelGrids, {
                        updateMessageBitmap()
                    })
                    .background(.thinMaterial)
                }
            }
        }
    }
}

#Preview {
    MessageView(
        message: .init(
            bitmap: [],
            flash: false,
            marquee: false,
            speed: .medium,
            mode: .animation
        )
    )
    
}


