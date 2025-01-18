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
    @StateObject var messageStore: MessageStore = MessageStore(messages: [
        .init(flash: false, marquee: false, speed: .medium, mode: .left)
    ])
    var body: some Scene {
        WindowGroup {
            ContentView()
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        BadgeSendButton(badgeManager: bluetoothManager, messages: messageStore.messages)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Picker("Messages", selection: .constant(1)) {
                                ForEach(0..<8, id: \.self) { index in
                                    Text("\(index + 1) Messages")
                                        .tag(index + 1)
                                }
                            }
                        }
                    }
                }
                .inspector(isPresented: .constant(true)) {
                    MessageInspector()
                        .inspectorColumnWidth(300)
                }
                .environmentObject(messageStore)
        }
    }
}
