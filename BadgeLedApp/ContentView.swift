import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = LEDBadgeManager()
    @StateObject private var pixelGridViewModel = PixelGridViewModel()
    @State var text: String = ""
    @State var speed: Double = 7
    @State private var asciiArt: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                LabeledContent(content: {
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
                }, label: {
                    Text("Status:")
                })
                TextField("Width:", value: $pixelGridViewModel.width, format: .number)
                Slider(value: $speed, in: 0...7, step: 1) {
                    Text("Speed:")
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
            .formStyle(.grouped)
            .frame(width: 400)
            Divider()
            PixelEditorView(viewModel: pixelGridViewModel)
                .background(.thickMaterial)
            Divider()
            HStack {
                Button("Clear All") {
                    pixelGridViewModel.clearAll()
                }
                .padding()
                Spacer()
                Button("Send to Badge") {
                    let hexStrings = pixelGridViewModel.toHexStrings()
                    print("Sending hex strings: \(hexStrings)")
                    bluetoothManager.sendBitmaps(bitmaps: hexStrings, speed: Int(speed))
                }
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
