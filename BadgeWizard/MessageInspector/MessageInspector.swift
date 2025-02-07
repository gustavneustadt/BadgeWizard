//
//  MessageInspector.swift
//  BadgeLedApp
//
//  Created by Gustav on 12.01.25.
//

import SwiftUI

struct MessageInspector: View {
    @EnvironmentObject var messageStore: MessageStore
    @Environment(\.undoManager) var undo
    
    var selectedMessageIndex: Int? {
        messageStore.messages.firstIndex { message in
            message.id == messageStore.selectedMessageId
        }
    }
    
    var selectedGridIndex: Int? {
        messageStore.selectedMessage?.pixelGrids.firstIndex(where: { grid in
            grid.id == messageStore.selectedGridId
        })
    }
    var body: some View {
        
        VStack(alignment: .leading) {
            Group {
                HStack {
                    Text("Message Configuration")
                    Spacer()
                    if selectedMessageIndex != nil {
                        Text("Message \(selectedMessageIndex!+1)")
                    } else {
                        Text("No Message selected")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                VStack(alignment: .leading) {
                    Text("Preview")
                    LEDPreviewView(
                        message: messageStore.selectedMessage
                    )
                }
                MessageFormView(
                    message: messageStore.selectedMessage
                )
                .padding(.top, 8)
            }
            .disabled(messageStore.selectedMessage == nil)
            
            Divider()
                .foregroundStyle(.clear)
            Group{
                HStack {
                    Text("Grid Configuration")
                    Spacer()
                    if selectedGridIndex != nil {
                        Text("Grid \(selectedGridIndex!+1)")
                    } else {
                        Text("No Grid selected")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                GridForm(grid: messageStore.selectedGrid)
                    .formStyle(.columns)
            }
            
            .disabled(selectedGridIndex == nil)
            Spacer()
        }
        .padding()
    }
    
}
