//
//  MessageView.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import SwiftUI
import Combine

struct MessageView: View {
    let message: Message?
    @EnvironmentObject var messageStore: MessageStore
    
    var body: some View {
        VStack(spacing: 8) {
            if message != nil {
                Header(
                    message: message!,
                    gridSum: message!.pixelGrids.count,
                    columnSum: message!.width,
                    selected: true
                )
                GridScroll(
                    message: message!
                )
            }
        }
        .frame(maxHeight: .infinity)
        .focusable(false)
        .onAppear {
            if let firstGrid = message?.pixelGrids.first {
                message?.selectGrid(firstGrid.id)                
            }
        }
    }
}
