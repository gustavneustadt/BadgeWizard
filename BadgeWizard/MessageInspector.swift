//
//  MessageInspector.swift
//  BadgeLedApp
//
//  Created by Gustav on 12.01.25.
//

import SwiftUI

struct MessageInspector: View {
    @EnvironmentObject var messageStore: MessageStore
    @State var selectedFontName: String = ""
    @State var selectedStyle: String = ""
    
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
                FontSelector(selectedFontName: $selectedFontName, selectedStyle: $selectedStyle)
                Spacer()
            }
            .padding()
            .formStyle(.columns)
        }
    }
    
}
