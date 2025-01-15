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
    
    var body: some View {
        VStack(spacing: 0) {
            
            VStack(alignment: .leading) {
                Text("Preview")
                LEDPreviewView(
                    message: messageStore.selectedMessage
                )
            }
            .padding([.horizontal, .top])
            Form {
                MessageFormView(
                    message: messageStore.selectedMessage
                )
                Divider()
                FontSelector(selectedFont: $selectedFontPostScript)
                Spacer()
            }
            .padding()
            .formStyle(.columns)
        }
    }
    
}
