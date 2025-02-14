//
//  MessageInspector.swift
//  BadgeLedApp
//
//  Created by Gustav on 12.01.25.
//

import SwiftUI

struct MessageInspector: View {
    @State var message: Message?
    @Environment(\.undoManager) var undo

    var body: some View {
        
        VStack(alignment: .leading) {
            Group {
                HStack {
                    Text("Message Configuration")
                    Spacer()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                VStack(alignment: .leading) {
                    Text("Preview")
                    LEDPreviewView(
                        message: message
                    )
                }
                MessageFormView(
                    message: message
                )
                .padding(.top, 8)
            }
            
            Divider()
                .foregroundStyle(.clear)
            Group{
                HStack {
                    Text("Grid Configuration")
                    Spacer()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                GridForm(grid: message?.getSelectedGrid())
                    .formStyle(.columns)
            }
            .disabled(message?.getSelectedGrid() == nil)
            Spacer()
        }
        .padding()
    }
    
}
