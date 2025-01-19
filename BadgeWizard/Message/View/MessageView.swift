//
//  MessageView.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import SwiftUI
import Combine

struct MessageView: View {
    @ObservedObject var message: Message
    let messageNumber: Int
    @State private var scrollViewSize: CGSize = .zero
    @EnvironmentObject var messageStore: MessageStore
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .trailing) {
                GridScroll(
                    message: message,
                    scrollViewSize: scrollViewSize
                )
                .getSize($scrollViewSize)
                Header(
                    messageNumber: messageNumber,
                    gridSum: message.pixelGrids.count,
                    columnSum: message.width,
                    selected: messageStore.selectedMessageId == message.id
                )
            }
        }
        .onTapGesture {
            messageStore.selectedMessageId = message.id
            
            guard message.pixelGrids.contains(where: { grid in
                grid.id == messageStore.selectedGridId
            }) == false else { return }
            messageStore.selectedGridId = message.pixelGrids.first?.id
        }
        .focusable(false)
    }
}
