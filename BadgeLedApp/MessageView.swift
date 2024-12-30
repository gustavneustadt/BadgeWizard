//
//  MessageView.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import SwiftUI

struct MessageView: View {
    @Binding var message: Message
    @StateObject var pixelGridViewModel: PixelGridViewModel = .init()
    @State private var showingForm = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .trailing) {
                ScrollView([.horizontal]) {
                    HStack {
                        PixelEditorView(viewModel: pixelGridViewModel)
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .frame(width: 5, height: 30)
                            .foregroundStyle(.secondary.opacity(0.5))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if pixelGridViewModel.width + Int(value.translation.width / 20) > 0 {
                                            pixelGridViewModel.width += Int(value.translation.width / 20)
                                        }
                                    }
                            )
                            .pointerStyle(.frameResize(position: .trailing))
                    }
                    .padding(.trailing, 300)
                    Text("\(pixelGridViewModel.width.formatted()) columns")
                        .monospaced()
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                }
                HStack {
                    Divider()
                    MessageFormView(message: $message, pixelGridViewModel: pixelGridViewModel)
                }
                .background(.thinMaterial)
            }
            // .padding(.horizontal)
        }
        .onChange(of: pixelGridViewModel.pixels) {
            message.bitmap = pixelGridViewModel.toHexStrings()
        }
        // .popover(
        //     isPresented: $showingForm,
        //     attachmentAnchor: .point(.top),
        //     arrowEdge: .top,
        //     content: {
        //         MessageFormView(message: $message, pixelGridViewModel: pixelGridViewModel)
        //     })
    }
}

struct MessageFormView: View {
    @Binding var message: Message    
    @ObservedObject var pixelGridViewModel: PixelGridViewModel
    @State var fontName: String = "Apple MacOS 8.0"
    @State var fontSize: Double = 11
    @State var kerning: Double = 0
    @State var text: String = ""
    
    func updateText() {
        let pixelData = textToPixels(text: text, font: fontName, size: fontSize, kerning: kerning)
        pixelGridViewModel.width = pixelData.width == 0 ? 1 : pixelData.width
        pixelGridViewModel.pixels = pixelData.pixels
    }
    
    var body: some View {
        Form {
            
                
                Slider(value: .init(get: {
                    Double(message.speed.rawValue)
                }, set: { val in
                    message.speed = Message.Speed(rawValue: Int(val)) ?? .verySlow
                }), in: 0...7, step: 1) {
                    Text("Speed:")
                }
                Toggle(isOn: $message.marquee) {
                    Text("Marquee")
                }
                Toggle(isOn: $message.flash) {
                    Text("Flashing")
                }
            
                    .padding(.bottom)
                        TextField("Kerning:", value: $kerning, format: .number)
                        TextField("Font Size:", value: $fontSize, format: .number)
                        TextField(text: $text) {
                            Text("Set text to:")
                        }
                        FontNameSelector(selectedFontName: $fontName)
                        Picker("Mode:", selection: $message.mode) {
                            ForEach(Message.Mode.allCases, id: \.self) { mode in
                                Text(mode.description).tag(mode)
                            }
                        }
                    
                    
            Spacer()
        }
        
        .frame(width: 200)
        .padding()
        .onChange(of: text) {
            updateText()
        }
        .onChange(of: fontSize) {
            updateText()
        }
        .onChange(of: fontName) {
            updateText()
        }
        .onChange(of: kerning) {
            updateText()
        }
    }
}

