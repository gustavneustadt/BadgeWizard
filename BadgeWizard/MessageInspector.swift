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
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Message Configuration")
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
                Text("Grid Configuration")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Button {
                        
                    } label: {
                        Spacer()
                        Text("Inverse Grid")
                        Spacer()
                    }
                    Button {
                        
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
