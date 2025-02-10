//
//  BadgeStudioView.swift
//  BadgeWizard
//
//  Created by Gustav on 09.02.25.
//

import SwiftUI

struct BadgeStudioView: View {
    @EnvironmentObject var messageStore: MessageStore
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 0) {
            MessageListView(messages: messageStore.messages)
            // List(messageStore.messages, rowContent: { message in
            //     MessageListItem(message: message)
                    // .onTapGesture(count: 2) {
                    //     openWindow(value: message)
                    // }
            // })
            Divider()
            HStack {
                Spacer()
                Button("Send to Badge") {
                    
                }
            }
            .padding()
            .background(.background)
        }
        .navigationTitle("Badge Studio")
        .toolbar {
            ToolbarItemGroup {
                Button {
                    if let message = messageStore.addMessage() {
                        openWindow(value: message)
                    }
                } label: {
                    Label("Create Message", systemImage: "plus")
                }
                
                Button {
                    openWindow(id: WindowType.messageLibrary.rawValue)
                } label: {
                    Label("Open Library", systemImage: "books.vertical")
                }
            }
        }
    }
}

#Preview {
    BadgeStudioView()
}
