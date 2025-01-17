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
    
    
    private var columnSum: Int {
        message.pixelGrids.reduce(0) { $0 + $1.width }
    }
    
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
                    columnSum: columnSum,
                    selected: messageStore.selectedMessageId == message.id
                )
            }
        }
        .onTapGesture {
            messageStore.selectedMessageId = message.id
        }
    }
}
