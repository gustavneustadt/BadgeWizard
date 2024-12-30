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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ForEach(messages) { message in
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
