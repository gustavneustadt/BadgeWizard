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
        @ObservedObject var message: Message
        let scrollViewSize: CGSize
        @Environment(\.undoManager) var undoManager
        @EnvironmentObject var messageStore: MessageStore
        
        var body: some View {
            ScrollView([.horizontal]) {
                HStack(spacing: 0) {
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
                        }
                        AddGridButton { duplicate in
                            message.addGrid(messageStore.selectedGrid, duplicateGrid: duplicate)
                        }
                        .offset(y: 13)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 48)
                .padding(.bottom, 24)
            }
        }
    }
}
