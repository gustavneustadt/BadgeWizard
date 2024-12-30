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
    @State var scrollViewSize: CGSize = .zero
    
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
                        Spacer()
                    }
                    .padding(.trailing, 300)
                    .frame(minWidth: scrollViewSize.width)
                }
                .getSize($scrollViewSize)
                HStack {
                    HStack {
                        Spacer()
                        VStack {
                            Text("\(pixelGridViewModel.width) Columns")
                                .monospaced()
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    HStack {
                        Divider()
                        MessageFormView(message: $message, pixelGridViewModel: pixelGridViewModel)
                    }
                    .background(.thinMaterial)
                }
            }
        }
        .onChange(of: pixelGridViewModel.pixels) {
            message.bitmap = pixelGridViewModel.toHexStrings()
        }
    }
}

struct MessageFormView: View {
    @Binding var message: Message
    @ObservedObject var pixelGridViewModel: PixelGridViewModel
    @State var fontName: String = "Apple MacOS 8.0"
    @State var fontSize: Double = 11
    @State var kerning: Double = 0
    @State var text: String = ""
    
    @State private var asciiArt: String = ""
    @State private var showImportSheet = false
    
    func updateText() {
        let pixelData = textToPixels(text: text, font: fontName, size: fontSize, kerning: kerning)
        pixelGridViewModel.width = pixelData.width == 0 ? 1 : pixelData.width
        
        if pixelData.width >= 1 {
            pixelGridViewModel.pixels = pixelData.pixels
        } else {
            pixelGridViewModel.erase()
        }
    }
    
    var body: some View {
        VStack {
            
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
                
                Picker("Mode:", selection: $message.mode) {
                    ForEach(Message.Mode.allCases, id: \.self) { mode in
                        Text(mode.description).tag(mode)
                    }
                }
                .padding(.bottom)
                TextField("Kerning:", value: $kerning, format: .number)
                TextField("Font Size:", value: $fontSize, format: .number)
                TextField(text: $text) {
                    Text("Set text to:")
                }
                FontNameSelector(selectedFontName: $fontName)
            }
            Spacer()
            Divider()
            HStack {
                Button {
                    pixelGridViewModel.erase()
                } label: {
                    Image(systemName: "eraser")
                    Text("Eraser")
                }

                Spacer()
                Menu("More") {
                    Button("Export as ASCII") {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(pixelGridViewModel.getAsciiArt(), forType: .string)
                    }
                    Button("Import…") {
                        showImportSheet = true
                    }
                }
                .frame(width: 70)
                .foregroundStyle(Color.accentColor)
            }
        }
        
        .frame(width: 200)
        .padding()
        .sheet(isPresented: $showImportSheet) {
            Section("Import ASCII Art") {
                VStack(alignment: .leading) {
                    TextEditor(text: $asciiArt)
                        .frame(height: 100)
                        .monospaced()
                    Button("Import") {
                        pixelGridViewModel.importAsciiArt(asciiArt)
                        // print(pixelGridViewModel.pixels)
                        asciiArt = "" // Clear the
                        showImportSheet = false
                    }
                    .disabled(asciiArt.isEmpty)
                }
                .padding()
            }
        }
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

