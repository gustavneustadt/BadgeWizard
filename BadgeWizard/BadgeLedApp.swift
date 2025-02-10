//
//  BadgeLedAppApp.swift
//  BadgeLedApp
//
//  Created by Gustav on 29.12.24.
//

import SwiftUI

@main
struct BadgeLedApp: App {
    
    @StateObject private var settingsStore = SettingsStore.shared
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
        Window("Badge Studio", id: "badge-studio", content: {
            BadgeStudioView()
                .frame(maxWidth: 300, maxHeight: 500)
                .windowResizeBehavior(.disabled)
                .environmentObject(messageStore)
            
        })
        .windowStyle(.hiddenTitleBar)
            .defaultSize(width: 300, height: 400)
        
        WindowGroup(for: Message.self) { $message in
            MessageEditorView(message: message)
                .environmentObject(settingsStore)
        }
        .defaultSize(width: 800, height: 600)
        
        // Message library window
        Window("Message Library", id: "message-library") {
            MessageLibraryView()  // For saved/preset messages
        }
        
        //
        //
        //         WindowGroup {
        //             ContentView()
        //                 .toolbar {
        //                     ToolbarItem(placement: .primaryAction) {
        //                         BadgeSendButton(badgeManager: bluetoothManager, messages: messageStore.messages)
        //                     }
        //
        //                     ToolbarItem {
        //                         ControlGroup {
        //
        //                             Button {
        //                                 settingsStore.decreaseSize()
        //                             } label: {
        //                                 Image(systemName: "minus.magnifyingglass")
        //                             }
        //
        //                             Button {
        //                                 settingsStore.increaseSize()
        //                             } label: {
        //                                 Image(systemName: "plus.magnifyingglass")
        //                             }
        //
        //                         } label: {
        //                             Text("Pixel Grid Zoom")
        //                         }
        //                     }
        //
        //                     ToolbarItem(placement: .principal) {
        //                         HStack {
        //                             Picker("Messages", selection: $messagesCount) {
        //                                 ForEach(0..<8, id: \.self) { index in
        //                                     Text("\(index + 1) Messages")
        //                                         .tag(index + 1)
        //                                 }
        //                             }
        //                         }
        //                     }
        //
        //
        //                     ToolbarItem {
        //                         Button {
        //                             showInspector.toggle()
        //                         } label: {
        //                             Image(systemName: "sidebar.trailing")
        //                         }
        //                     }
        //                     .hidden(showInspector)
        //                 }
        //                 .inspector(isPresented: $showInspector) {
        //                     MessageInspector()
        //                         .inspectorColumnWidth(300)
        //                 }
        //                 .onChange(of: messagesCount) { _, newValue in
        //                     withAnimation(.easeInOut(duration: 0.2)) {
        //                         messageStore.updateMessageCount(to: newValue, undoManager: undoManager)
        //                     }
        //                 }
        //                 .onChange(of: messageStore.messages.count, initial: true) { _, newValue in
        //                     guard messagesCount != newValue else { return }
        //                     messagesCount = newValue
        //                 }
        //                 .environmentObject(messageStore)
        //                 .environmentObject(settingsStore)
        //         }
        //         .commands {
        // #if DEBUG
        //             CommandGroup(after: .newItem) {
        //                 Button("Export Message as Debug Code") {
        //                     messageStore.selectedMessage?.copyDebugCodeToClipboard()
        //                 }
        //             }
        // #endif
        //
        //         }
        .modelContainer(for: Message.self, isUndoEnabled: true)
    }
}
