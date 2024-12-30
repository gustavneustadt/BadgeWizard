import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = LEDBadgeManager()
    @State var messagesCount: Int = 1
    @State var messages: [Message] = [
        Message(
            bitmap: [],
            flash: false,
            marquee: false,
            speed: .steady,
            mode: .left
        )
    ]
    
    func appendNewMessage() {
        messages.append(
            Message(
                bitmap: [],
                flash: false,
                marquee: false,
                speed: .steady,
                mode: .left
            )
        )
    }
    
    // Get text representation of the pixel grid
    // var textRepresentation: String {
    //     var result = ""
    //     var lastRow = 0
    //     for (i, row) in pixelGridViewModel.pixels.enumerated() {
    //         if lastRow != i {
    //             result.append("\n")
    //             lastRow = i
    //         }
    //         for pixel in row {
    //             if pixel.isOn {
    //                 result.append("O")
    //             } else {
    //                 result.append("-")
    //             }
    //         }
    //     }
    //     return result
    // }
    
    // func updateText() {
    //     let pixelData = textToPixels(text: text, font: fontName, size: fontSize, kerning: kerning)
    //     pixelGridViewModel.width = pixelData.width == 0 ? 1 : pixelData.width
    //     pixelGridViewModel.pixels = pixelData.pixels
    // }
    //
    // func getMessage() -> Message {
    //     Message(
    //         bitmap: pixelGridViewModel.toHexStrings(),
    //         flash: flashing,
    //         marquee: marquee,
    //         speed: speed,
    //         mode: mode
    //     )
    // }
    //
    // func getDifferentMessage() -> Message {
    //     Message(
    //         bitmap: pixelGridViewModel.toHexStrings(),
    //         flash: flashing,
    //         marquee: marquee,
    //         speed: speed,
    //         mode: .snowflake
    //     )
    // }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ForEach($messages) { message in
                            MessageView(message: message)
                        Divider()
                    }
                }
                Spacer()
            }
            Divider()
            HStack {
                Picker("Messages:", selection: $messagesCount) {
                    ForEach(1..<9) { i in
                        Text("\(i) Messages")
                            .tag(i)
                    }
                }
                .labelsHidden()
                .frame(maxWidth: 150)
                .onChange(of: messagesCount) {
                    Task {
                        while messages.count < messagesCount {
                            appendNewMessage()
                        }
                        while messages.count > messagesCount {
                            _ = messages.popLast()
                        }                        
                    }
                }
                
                Spacer()
                Spacer()
                BadgeSendButton(badgeManager: bluetoothManager, messages: messages)
            }
            .padding()
            .background(.thinMaterial)
        }
    }
}


#Preview {
    ContentView()
    // .frame(height: 300)
}
