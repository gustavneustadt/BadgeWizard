//
//  MessageFormView.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//


import SwiftUI
import SwiftUI

struct MessageFormView: View {
    
    @Binding var mode: Message.Mode
    
    @Binding var marquee: Bool
    @Binding var flash: Bool
    @Binding var speed: Message.Speed
    
    @State private var asciiArt: String = ""
    @State private var showImportSheet = false
    
    var body: some View {
        return VStack {
            Form {
                Picker("Mode:", selection: $mode) {
                    ForEach(Message.Mode.allCases, id: \.self) { mode in
                        Text(mode.description).tag(mode)
                    }
                }
                
                Slider(value: .init(get: {
                    Double(speed.rawValue)
                }, set: { val in
                    speed = Message.Speed(rawValue: Int(val)) ?? .verySlow
                }), in: 0...7, step: 1) {
                    Text("Speed:")
                }
                
                
                HStack {
                    Toggle(isOn: $marquee) {
                        Text("Marquee")
                    }
                    Toggle(isOn: $flash) {
                        Text("Flashing")
                    }
                }
            }
            .padding(.top)
        }
    }
}
