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
    @State var selectedWeight: NSFont.Weight = NSFont.Weight.regular
    
    var body: some View {
        Form {
            FontSelector(selectedFontName: $selectedFontName, selectedWeight: $selectedWeight)
            form
            Spacer()
        }
        .padding()
        .formStyle(.columns)
    }
    
    let previewTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var form: some View {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Preview")
                    if messageStore.selectedMessage != nil {
                        LEDPreviewView(
                            message: messageStore.selectedMessage!,
                            timer: previewTimer
                        )
                    }
                }
                
                if messageStore.selectedMessage != nil {
                    MessageFormView(
                        message: messageStore.selectedMessage!
                    )
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: 300)
    }
}
