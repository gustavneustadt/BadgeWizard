//
//  MessageInspector.swift
//  BadgeLedApp
//
//  Created by Gustav on 12.01.25.
//

import SwiftUI

struct MessageInspector: View {
    @EnvironmentObject var messageStore: MessageStore
    @State var selectedFontPostScript: String = ""
    @State var showAppleTextPopover: Bool = false
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
                .formStyle(.columns)
                .padding(8)
            }
            .disabled(messageStore.selectedMessage == nil)
            
            Divider()
                .foregroundStyle(.clear)
            Group {
                HStack {
                    Text("Grid Configuration")
                    Spacer()
                    if selectedGridIndex != nil {
                        Text("Grid \(selectedGridIndex!+1)")
                    }
                }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Button {
                        messageStore.selectedGrid?.invertPixels(undoManager: undo)
                    } label: {
                        Spacer()
                        Text("Inverse Grid")
                        Spacer()
                    }
                    Button {
                        messageStore.selectedGrid?.erase(undoManager: undo)
                    } label: {
                        Spacer()
                        Text("Clear Grid")
                        Spacer()
                    }
                }

                Toggle(isOn: $showAppleTextPopover) {
                    Spacer()
                    Text("Add Text")
                    Spacer()
                }
                .toggleStyle(.button)
                .popover(isPresented: $showAppleTextPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom, content: {
                    Form {
                        FontSelector(selectedFont: $selectedFontPostScript)
                        Stepper(value: .constant(0), format: .number) {
                            Text("Kerning:")
                        }
                        TextField("Text:", text: .constant(""), prompt: Text("Refugees Welcome"))
                            .padding(.top)
                    }
                    .padding()
                })
            }
            .disabled(messageStore.selectedGridId == nil)
            Spacer()
        }
        .padding()
    }
    
}
