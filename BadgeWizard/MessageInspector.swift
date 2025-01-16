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
        VStack {
            
            VStack(alignment: .leading) {
                Text("Preview")
                LEDPreviewView(
                    message: messageStore.selectedMessage
                )
            }
            GroupBox {
                MessageFormView(
                    message: messageStore.selectedMessage
                )
                .formStyle(.columns)
                .padding(8)
            }
            
            Toggle(isOn: $showAppleTextPopover) {
                Spacer()
                Text("Apple Text")
                Spacer()
            }
            .toggleStyle(.button)
            .controlSize(.large)
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
            Spacer()
        }
        .padding()
    }
    
}
