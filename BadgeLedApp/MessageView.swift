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
        pixelGrids.append(.init(parent: self))
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
    
    func combineGrids(_ grids: [[String]]) -> [String] {
        guard !grids.isEmpty else { return [] }
        
        let numberOfRows = grids[0].count
        var result: [String] = []
        
        for rowIndex in 0..<numberOfRows {
            // Combine each row across all grids
            let combinedRow = grids.map { $0[rowIndex] }.joined()
            result.append(combinedRow)
        }
        
        return result
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .trailing) {
                ScrollView([.horizontal]) {
                    HStack(spacing: 2) {
                        HStack {
                            ForEach (gridState.pixelGrids) { grid in
                                GridView(pixelGrid: grid) { val in
                                    grid.width = val
                                }
                                .onChange(of: grid) {
                                    message.bitmap = combineGrids(
                                        gridState.pixelGrids.compactMap({ grid in
                                            grid.toHexStrings()
                                        })
                                    )
                                }
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


