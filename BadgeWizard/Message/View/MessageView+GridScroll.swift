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
        @Bindable var message: Message
        @Environment(\.undoManager) var undoManager
        @EnvironmentObject var messageStore: MessageStore
        
        var body: some View {
            ScrollView([.horizontal]) {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(message.pixelGrids) { grid in
                            PixelGridView(
                                pixelGrid: grid,
                                onTrailingWidthChanged: { val in
                                    grid.resizeFromTrailingEdge(to: val, undoManager: undoManager)
                                },
                                onLeadingWidthChanged: { val in
                                    // grid.resizeFromLeadingEdge(to: val)
                                }
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
            }
        }
    }
}
