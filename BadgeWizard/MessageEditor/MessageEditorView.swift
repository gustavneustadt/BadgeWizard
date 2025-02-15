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
    @EnvironmentObject var messageStore: MessageStore
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
                    message: message,
                    messageNumber: 1
                )
                .onAppear {
                    if isNewMessage {
                        messageStore.addToStore(message!)
                    }
                }
            }
            .toolbar {
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
            }
            .inspector(isPresented: $showInspector) {
                if message != nil {
                    MessageInspector(message: message)
                        .inspectorColumnWidth(300)
                }
            }
    }
}
