import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = LEDBadgeManager()
    private let sharedPreviewTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State var messagesCount: Int = 1
    @State var messages: [Message] = [
        Message(
            flash: false,
            marquee: false,
            speed: .steady,
            mode: .left
        )
    ]
    
    func appendNewMessage() {
        messages.append(
            Message(
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
                LazyVStack(spacing: 0) {
                    ForEach(messages.indices, id: \.self) { index in
                        MessageView(
                            message: messages[index],
                            messageNumber: index+1,
                            previewTimer: sharedPreviewTimer
                        )
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
