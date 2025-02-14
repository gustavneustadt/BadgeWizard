//
//  GridScroll.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//


import SwiftUI
import Combine

extension MessageView {
    struct GridScroll: View {
        @State var message: Message
        @Environment(\.undoManager) var undoManager
        @EnvironmentObject var messageStore: MessageStore
        
        var body: some View {
            ScrollView([.horizontal]) {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(message.pixelGrids) { grid in
                            PixelGridView(
                                pixelGrid: grid
                            )
                            .zIndex(message.selectedGridId == grid.id ? 1 : 0)
                            
                        }
                        AddGridButton { duplicate in
                            withAnimation(.easeOut(duration: 0.2)) {
                                message.newGrid(message.getSelectedGrid(), duplicateGrid: duplicate)
                            }
                        }
                        .offset(y: 13)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                #if PIXELGRID_VIEW_DEBUG
                .background(
                    Color.init(hue: Double.random(in: 0...1), saturation: 0.5, brightness: 0.4)
                )
                #endif
            }
        }
    }
}
