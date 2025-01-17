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
                    // Primary action button
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            
                        } label: {
                            Image(systemName: "wand.and.sparkles")
                            Text("Send to Badge")
                        }
                    }
                    
                    // Menu in toolbar
                    ToolbarItem(placement: .automatic) {
                        // Picker("Messages", selection: .constant(1)) {
                        //     ForEach(0..<8, id: \.self) { index in
                        //         Text(index+1)
                        //             .tag(index+1)
                        //     }
                        //     
                        // }
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
