//
//  MessageEditor.swift
//  BadgeWizard
//
//  Created by Gustav on 09.02.25.
//

import SwiftUI

struct MessageEditorView: View {
    var message: Message?
    @State var showInspector: Bool = true
    @Environment(\.undoManager) var undoManager
    @EnvironmentObject private var messageStore: MessageStore
    @EnvironmentObject private var bluetoothManager: LEDBadgeManager
    @EnvironmentObject private var settingsStore: SettingsStore
    let isNewMessage: Bool
    
    init(message: Message? = nil) {
        guard message == nil else {
            self.message = message
            isNewMessage = false
            return
        }
        
        self.message = Message()
        isNewMessage = true
    }
    
    var body: some View {
        VStack {
            if message == nil {
                Spacer()
                ProgressView()
                Text("Loading Message …")
                Spacer()
                
            }
            MessageView(
                message: message
            )
            .onAppear {
                if isNewMessage {
                    messageStore.addToStore(message!)
                }
            }
        }
        .toolbar {
            // ToolbarItem(placement: .primaryAction) {
            //     BadgeSendButton(badgeManager: bluetoothManager, messages: messageStore.messages)
            // }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    
                } label: {
                    Image("grid.text")
                    Text("Add Text")
                }

            }
            
            ToolbarItem {
                ControlGroup {
                    
                    Button {
                        settingsStore.decreaseSize()
                    } label: {
                        Image(systemName: "minus.magnifyingglass")
                    }
                    
                    Button {
                        settingsStore.increaseSize()
                    } label: {
                        Image(systemName: "plus.magnifyingglass")
                    }
                    
                } label: {
                    Text("Pixel Grid Zoom")
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
            if message != nil {
                MessageInspector(message: message)
                    .inspectorColumnWidth(300)
            }
        }
}
}
