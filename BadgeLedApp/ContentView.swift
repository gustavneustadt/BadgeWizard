import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = LEDBadgeManager()
    @State var text: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("LED Badge Test")
                .font(.title)
            
            Text("Status: \(bluetoothManager.connectionStatus)")
            HStack {
                TextField(text: $text) {
                    Text("String")
                }
                Button("Send …") {
                    bluetoothManager.sendText(text, speed: 7)
                }
                .disabled(bluetoothManager.connectionStatus != "Connected")
            }
            Button(action: {
                bluetoothManager.startScanning()
            }) {
                Text(bluetoothManager.isScanning ? "Scanning..." : "Connect")
                    .frame(width: 200)
            }
            .disabled(bluetoothManager.isScanning)
            
            PixelEditorView(bluetoothManager: bluetoothManager)
        }
        .padding()
    }
}
