//
//  MessageInspector.swift
//  BadgeLedApp
//
//  Created by Gustav on 12.01.25.
//

import SwiftUI

struct MessageInspector: View {
    @EnvironmentObject var messageStore: MessageStore
    @State var selectedFontPostscriptName: String = ""
    @State var showAppleTextPopover: Bool = false
    @State var fontSize: Double = 11
    @State var kerning: Double = 0
    @State var text: String = ""
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
    
    func updateText() {
        messageStore.selectedGrid?.applyText(text, postscriptFontName: selectedFontPostscriptName, size: fontSize, kerning: kerning)
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
                    } else {
                        Text("No Grid selected")
                    }
                }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Group {
                    Button {
                        messageStore.selectedGrid?.invert(undoManager: undo)
                    } label: {
                        Spacer()
                        Text("Invert Grid")
                        Spacer()
                    }
                    Toggle(isOn: $showAppleTextPopover) {
                        Spacer()
                        Text("Add Text")
                        Spacer()
                    }
                    .toggleStyle(.button)
                    .popover(isPresented: $showAppleTextPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom, content: {
                        Form {
                            Text("Font: \(selectedFontPostscriptName)")
                            FontSelector(selectedFont: $selectedFontPostscriptName)
                            Stepper(value: $kerning, format: .number) {
                                Text("Kerning:")
                            }
                            Stepper(value: $fontSize, format: .number) {
                                Text("Size:")
                            }
                            TextField("Text:", text: $text, prompt: Text("Refugees Welcome"))
                                .padding(.top)
                        }
                        .padding()
                    })
                    Button {
                        messageStore.selectedGrid?.clear(undoManager: undo)
                    } label: {
                        Spacer()
                        Text("Clear Grid")
                        Spacer()
                    }
                    Button {
                        messageStore.deleteGrid(messageStore.selectedGridId!)
                    } label: {
                        Spacer()
                        Text("Delete Grid")
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .disabled(selectedGridIndex == nil)
            Spacer()
        }
        .padding()
        .onChange(of: text) {
            updateText()
        }
        .onChange(of: kerning) {
            guard !text.isEmpty else { return }
            updateText()
        }
        .onChange(of: fontSize) {
            guard !text.isEmpty else { return }
            updateText()
        }
        .onChange(of: selectedFontPostscriptName) {
            guard !text.isEmpty else { return }
            updateText()
        }
    }
    
}
