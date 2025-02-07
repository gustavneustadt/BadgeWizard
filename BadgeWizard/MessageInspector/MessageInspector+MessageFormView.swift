//
//  MessageFormView.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//


import SwiftUI
import SwiftUI

extension MessageInspector {
    struct MessageFormView: View {
        @Bindable var message: Message
        
        init(message: Message?) {
            self.message = message ?? Message.placeholder()
        }
        
        var body: some View {
            
            Form {
                Picker("Mode:", selection: $message.mode) {
                    ForEach(Message.Mode.allCases, id: \.self) { mode in
                        Text(mode.description).tag(mode)
                    }
                }
                
                Slider(value: .init(get: {
                    Double(message.speed.rawValue)
                }, set: { val in
                    message.speed = Message.Speed(rawValue: Int(val)) ?? .verySlow
                }), in: 0...7, step: 1) {
                    Text("Speed:")
                }
                
                HStack {
                    Toggle(isOn: $message.marquee) {
                        Text("Marquee")
                    }
                    Toggle(isOn: $message.flash) {
                        Text("Flashing")
                    }
                }
            }
            .formStyle(.columns)
        }
    }
}
