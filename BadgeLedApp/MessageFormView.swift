//
//  MessageFormView.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//


import SwiftUI
import SwiftUI

struct MessageFormView: View {
    // let updatePixels: ([[Pixel]], Int) -> Void
    // let erasePixels: () -> Void
    // let getAsciiArt: () -> String
    
    // @State var fontName: String = "Apple MacOS 8.0"
    // @State var fontSize: Double = 11
    // @State var kerning: Double = 0
    // @State var text: String = ""
    
    @Binding var mode: Message.Mode
    
    @Binding var marquee: Bool
    @Binding var flash: Bool
    @Binding var speed: Message.Speed
    
    @State private var asciiArt: String = ""
    @State private var showImportSheet = false
    
    // func updateText() {
    //     let pixelData = textToPixels(text: text, font: fontName, size: fontSize, kerning: kerning)
    //     let width = pixelData.width == 0 ? 1 : pixelData.width
    //     
    //     if pixelData.width >= 1 {
    //         updatePixels(pixelData.pixels, width)
    //     } else {
    //         erasePixels()
    //     }
    // }
    
    var body: some View {
        return VStack {
            Form {
                Slider(value: .init(get: {
                    Double(speed.rawValue)
                }, set: { val in
                    speed = Message.Speed(rawValue: Int(val)) ?? .verySlow
                }), in: 0...7, step: 1) {
                    Text("Speed:")
                }
                Toggle(isOn: $marquee) {
                    Text("Marquee")
                }
                Toggle(isOn: $flash) {
                    Text("Flashing")
                }
                
                Picker("Mode:", selection: $mode) {
                    ForEach(Message.Mode.allCases, id: \.self) { mode in
                        Text(mode.description).tag(mode)
                    }
                }
                // .padding(.bottom)
                // TextField("Kerning:", value: $kerning, format: .number)
                // TextField("Font Size:", value: $fontSize, format: .number)
                // TextField(text: $text) {
                //     Text("Set text to:")
                // }
                // FontNameSelector(selectedFontName: $fontName)
            }
            // HStack {
            //     Button {
            //         erasePixels()
            //     } label: {
            //         Image(systemName: "eraser")
            //         Text("Eraser")
            //     }
            //     
            //     Spacer()
            //     Menu("More") {
            //         Button("Export as ASCII") {
            //             let pasteboard = NSPasteboard.general
            //             pasteboard.clearContents()
            //             pasteboard.setString(getAsciiArt(), forType: .string)
            //         }
            //         Button("Import…") {
            //             showImportSheet = true
            //         }
            //     }
            //     .frame(width: 70)
            //     .foregroundStyle(Color.accentColor)
            // }
        }
        // .frame(width: 200)
        // .sheet(isPresented: $showImportSheet) {
        //     Section("Import ASCII Art") {
        //         VStack(alignment: .leading) {
        //             TextEditor(text: $asciiArt)
        //                 .frame(height: 100)
        //                 .monospaced()
        //             Button("Import") {
        //                 // pixelGridViewModel.pixelFromString(text: asciiArt)
        //                 asciiArt = "" // Clear the
        //                 showImportSheet = false
        //             }
        //             .disabled(asciiArt.isEmpty)
        //         }
        //         .padding()
        //     }
        // }
        // .onChange(of: text) {
        //     updateText()
        // }
        // .onChange(of: fontSize) {
        //     updateText()
        // }
        // .onChange(of: fontName) {
        //     updateText()
        // }
        // .onChange(of: kerning) {
        //     updateText()
        // }
    }
}
