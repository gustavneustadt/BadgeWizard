import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = LEDBadgeManager()
    @StateObject private var pixelGridViewModel = PixelGridViewModel()
    @State var text: String = ""
    @State var speed: Double = 7
    @State private var asciiArt: String = ""
    @State var flashing: Bool = false
    @State var marquee: Bool = false
    @State var mode: Int = 0
    @State var fontName: String = "Apple MacOS 8.0"
    @State var fontSize: Double = 11
    
    // Get text representation of the pixel grid
    var textRepresentation: String {
        var result = ""
        var lastRow = 0
        for (i, row) in pixelGridViewModel.pixels.enumerated() {
            if lastRow != i {
                result.append("\n")
                lastRow = i
            }
            for pixel in row {
                if pixel.isOn {
                    result.append("O")
                } else {
                    result.append("-")
                }
            }
        }
        return result
    }
    
    var body: some View {
        VStack(spacing: 0) {
                Form {
                    
                    Slider(value: $speed, in: 0...7, step: 1) {
                        Text("Speed:")
                    }
                    Toggle(isOn: $marquee) {
                        Text("Marquee")
                    }
                    Toggle(isOn: $flashing) {
                        Text("Flashing")
                    }
                    
                    TextField("Font Size:", value: $fontSize, format: .number)
                    TextField(text: $text) {
                        Text("Set text to:")
                    }
                    .onSubmit {
                        let pixelData = textToPixels(text: text, font: fontName, size: fontSize)
                        pixelGridViewModel.width = pixelData.width
                        pixelGridViewModel.pixels = pixelData.pixels
                    }
                    FontNameSelector(selectedFontName: $fontName)
                    Picker("Mode:", selection: $mode) {
                        Text("Right to Left")
                            .tag(0)
                        Text("Left to Right")
                            .tag(1)
                        Text("Up")
                            .tag(2)
                        Text("Down")
                            .tag(3)
                        Text("Fixed Centerd")
                            .tag(4)
                        Text("Fixed Left Aligned")
                            .tag(5)
                        Text("Snowflake")
                            .tag(6)
                        Text("Animation")
                            .tag(7)
                        Text("Laser")
                            .tag(8)
                    }
                }
                .formStyle(.grouped)
                .frame(width: 400)
            Divider()
            ScrollView([.horizontal]) {
                VStack(spacing: 8) {
                    HStack(spacing: 0) {
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
                    .padding(.horizontal)
                    Text("\(pixelGridViewModel.width.formatted()) columns")
                        .monospaced()
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                
                Section("Import ASCII Art") {
                    TextEditor(text: $asciiArt)
                        .frame(height: 100)
                    Button("Import") {
                        pixelGridViewModel.importAsciiArt(asciiArt)
                        asciiArt = "" // Clear the input after import
                    }
                    .disabled(asciiArt.isEmpty)
                }
            }
            .background(.thickMaterial)
            Divider()
            HStack {
                Button("Clear All") {
                    pixelGridViewModel.clearAll()
                }
                .padding()
                Spacer()
                HStack {
                    if bluetoothManager.isConnected {
                        Label(title: {
                            Text("Connected")
                        }) {
                            Image(systemName: "checkmark")
                        }
                        .foregroundStyle(.green)
                    } else {
                        Text("Disconnected")
                            .foregroundStyle(.secondary)
                    }
                    Button(action: {
                        bluetoothManager.startScanning()
                    }) {
                        Text(
                            bluetoothManager.isScanning ? "Scanning..." : "Connect"
                        )
                    }
                    .disabled(bluetoothManager.isScanning)
                }
                Button("Send to Badge") {
                    let hexStrings = pixelGridViewModel.toHexStrings()
                    print("Sending hex strings: \(hexStrings)")
                    bluetoothManager.sendBitmaps(
                        bitmaps: hexStrings,
                        speed: Int(speed),
                        flash: flashing,
                        marquee: marquee,
                        mode: mode
                    )
                }
                .disabled(!bluetoothManager.isConnected)
                .padding()
            }
            .padding(8)
            .background(.thinMaterial)
        }
    }
}


#Preview {
    ContentView()
        .frame(height: 300)
}
