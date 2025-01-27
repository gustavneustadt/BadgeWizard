//
//  BadgeLedAppApp.swift
//  BadgeLedApp
//
//  Created by Gustav on 29.12.24.
//

import SwiftUI

@main
struct BadgeLedApp: App {
    
    @StateObject private var bluetoothManager = LEDBadgeManager()
    
#if DEBUG
    @StateObject var messageStore: MessageStore = MessageStore(messages: [
        Message.testMessage
    ])
#else
    @StateObject var messageStore: MessageStore = MessageStore(messages: [
        .init(flash: false, marquee: false, speed: .medium, mode: .left)
    ])
#endif
    
    @State var messagesCount: Int = 1
    @State var showInspector: Bool = true
    @Environment(\.undoManager) var undoManager
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        BadgeSendButton(badgeManager: bluetoothManager, messages: messageStore.messages)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Picker("Messages", selection: $messagesCount) {
                                ForEach(0..<8, id: \.self) { index in
                                    Text("\(index + 1) Messages")
                                        .tag(index + 1)
                                }
                            }
                        }
                    }
                    
                    ToolbarItem {
                        Button {
                            showInspector.toggle()
                        } label: {
                            Image(systemName: "sidebar.trailing")
                        }
                    }
                    .hidden(showInspector)
                }
                .inspector(isPresented: $showInspector) {
                    MessageInspector()
                        .inspectorColumnWidth(300)
                }
                .environmentObject(messageStore)
                .onChange(of: messagesCount) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        messageStore.updateMessageCount(to: newValue, undoManager: undoManager)
                    }
                }
                .onChange(of: messageStore.messages.count, initial: true) { _, newValue in
                    guard messagesCount != newValue else { return }
                    messagesCount = newValue
                }
        }
        .commands {
#if DEBUG
            CommandGroup(after: .newItem) {
                Button("Export Message as Debug Code") {
                    messageStore.selectedMessage?.copyDebugCodeToClipboard()
                }
            }
#endif
            
        }
    }
}
