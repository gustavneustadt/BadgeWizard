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
                .inspector(isPresented: .constant(true)) {
                    // MessageInspector(selectionManager: selectionManager)
                }
                .environmentObject(messageStore)
        }
    }
}
