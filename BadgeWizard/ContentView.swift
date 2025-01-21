import SwiftUI

struct ContentView: View {
    @EnvironmentObject var messageStore: MessageStore
    @EnvironmentObject private var bluetoothManager: LEDBadgeManager
    private let sharedPreviewTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(messageStore.messages.indices, id: \.self) { index in
                        MessageView(
                            message: messageStore.messages[index],
                            messageNumber: index+1
                        )
                        
                        // if last item, hide divider
                        if index != messageStore.messages.count-1 {
                            Divider()
                        }
                    }
                    if messageStore.messages.count < 8 {
                        Divider()
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                messageStore.addMessage()                                
                            }
                        } label: {
                            Image(systemName: "plus.rectangle")
                            Text("Add Message")
                        }
                        .controlSize(.large)
                        .padding()
                    }

                }
                Spacer()
            }
        }
    }
}
