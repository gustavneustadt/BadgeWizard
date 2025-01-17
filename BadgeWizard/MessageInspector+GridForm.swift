//
//  MessageInspector+GridForm.swift
//  BadgeWizard
//
//  Created by Gustav on 19.01.25.
//

import SwiftUI

extension MessageInspector {
    
    struct GridForm: View {
        @ObservedObject var grid: PixelGrid
        @ObservedObject var message: Message
        @State var selectedFontPostscriptName: String = ""
        @State var showAppleTextPopover: Bool = false
        @State var fontSize: Double = 11
        @State var kerning: Double = 0
        @State var text: String = ""
        @Environment(\.undoManager) var undo
        
        init(grid: PixelGrid?) {
            self.grid = grid ?? PixelGrid.placeholder()
            self.message = grid?.message ?? Message.placeholder()
        }
        
        func updateText() {
            grid.applyText(text, postscriptFontName: selectedFontPostscriptName, size: fontSize, kerning: kerning)
        }

        var body: some View {
            Form {
                Toggle(isOn: $message.onionSkinning) {
                    Text("Onion Skinning")
                }
                
                Toggle(isOn: $showAppleTextPopover) {
                    Spacer()
                    Image("grid.text")
                    Text("Add Text")
                    Spacer()
                }
                .toggleStyle(.button)
                .popover(isPresented: $showAppleTextPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom, content: {
                    Form {
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
                Divider()
                    .foregroundStyle(.clear)
                Button {
                    grid.invert(undoManager: undo)
                } label: {
                    Spacer()
                    Image(systemName: "arrow.2.squarepath")
                    Text("Invert Grid")
                    Spacer()
                }
                Button {
                    grid.clear(undoManager: undo)
                } label: {
                    Spacer()
                    Image("grid.rectangle")
                    Text("Clear Grid")
                    Spacer()
                }
                Button {
                    grid.deleteGrid()
                } label: {
                    Spacer()
                    Image(systemName: "delete.left.fill")
                    Text("Delete Grid")
                    Spacer()
                }
                .disabled(message.pixelGrids.count == 1)
            }
            .frame(maxWidth: .infinity)
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
}
