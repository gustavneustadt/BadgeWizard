//
//  MessageView.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import SwiftUI
import Combine

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
    
    let previewTimer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    var columnSum: Int {
        gridState.pixelGrids.reduce(0) { $0 + $1.width }
    }
    
    func updateMessageBitmap() {
        let pixels = gridState.pixelGrids.map({ grid in
            
            if message.mode == .picture {
                return Message.combinePixelArrays([grid.pixels, self.createPadding()])
            }
            
            return grid.pixels
        })
        let combinedPixel = Message.combinePixelArrays(pixels)
        let pixelHexStrings = Message.pixelsToHexStrings(pixels: combinedPixel)
        
        message.bitmap = pixelHexStrings
    }
    
    func createPadding() -> [[Pixel]] {
        let width = 4
        let height = 11
        return (0..<height).map { y in
            (0..<width).map { x in
                Pixel(x: x, y: y, isOn: false)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .trailing) {
                    ScrollView([.horizontal]) {
                        HStack(spacing: 0) {
                            HStack(spacing: 8) {
                                ForEach (gridState.pixelGrids) { grid in
                                    GridView(
                                        pixelGrid: grid,
                                        onTrailingWidthChanged: { val in
                                            grid.resizeFromTrailingEdge(to: val)
                                        },
                                        onLeadingWidthChanged: { val in
                                            grid.resizeFromLeadingEdge(to: val)
                                        },
                                        onPixelChanged: updateMessageBitmap)
                                }
                                VStack {
                                    
                                    
                                    Button {
                                        gridState.addGrid()
                                    } label: {
                                        Label {
                                            Text("Add Grid")
                                        } icon: {
                                            Image("square.plus")
                                        }

                                    }
                                    .controlSize(.extraLarge)
                                }
                            }
                            Spacer()
                        }
                        .padding(.trailing, 300)
                        .frame(minWidth: scrollViewSize.width * 2)
                        .padding(.horizontal)
                        .padding(.vertical, 32)
                    }
                    .getSize($scrollViewSize)
                HStack(spacing: 0) {
                    HStack {
                        VStack {
                            Text("Message ")
                                .monospaced()
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        Spacer()
                        VStack {
                            Text("\(columnSum) Columns in Total")
                                .monospaced()
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                    .padding(8)
                    HStack(spacing: 0) {
                        Divider()
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text("Preview")
                                LEDPreviewView(
                                    pixels: Message.combinePixelArrays(
                                        gridState.pixelGrids.map({ grid in
                                            grid.pixels
                                        })
                                    ),
                                    mode: message.mode,
                                    speed: message.speed,
                                    flash: message.flash,
                                    marquee: message.marquee,
                                    timer: previewTimer
                                )
                            }
                            
                            MessageFormView(
                                mode: $message.mode,
                                marquee: $message.marquee,
                                flash: $message.flash,
                                speed: $message.speed
                            )
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: 300)
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
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    MessageView(
        message: .init(
            bitmap: [],
            flash: false,
            marquee: false,
            speed: .medium,
            mode: .animation
        ), previewTimer: timer
    )
    
}


