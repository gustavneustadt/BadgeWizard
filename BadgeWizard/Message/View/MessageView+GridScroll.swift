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
        let onPixelChanged: () -> Void
        
        var body: some View {
            ScrollView([.horizontal]) {
                HStack(spacing: 0) {
                    HStack(spacing: 8) {
                        ForEach(message.pixelGrids) { grid in
                            PixelGridView(
                                pixelGrid: grid,
                                onTrailingWidthChanged: { val in
                                    grid.resizeFromTrailingEdge(to: val)
                                },
                                onLeadingWidthChanged: { val in
                                    grid.resizeFromLeadingEdge(to: val)
                                },
                                onPixelChanged: onPixelChanged
                            )
                        }
                        AddGridButton {
                            message.addGrid()
                        }
                    }
                    Spacer()
                }
                .padding(.trailing, 300)
                .frame(minWidth: scrollViewSize.width * 2)
                .padding(.horizontal)
                .padding(.top, 48)
                .padding(.bottom)
            }
        }
    }
}