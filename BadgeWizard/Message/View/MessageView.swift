//
//  MessageView.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import SwiftUI
import Combine

struct MessageView: View {
    @Bindable var message: Message
    let messageNumber: Int
    @EnvironmentObject var messageStore: MessageStore
    
    var body: some View {
        VStack(spacing: 8) {
            Header(
                message: message,
                messageNumber: messageNumber,
                gridSum: message.pixelGrids.count,
                columnSum: message.width,
                selected: true
            )
            GridScroll(
                message: message
            )
        }
        .frame(maxHeight: .infinity)
        .focusable(false)
    }
}
