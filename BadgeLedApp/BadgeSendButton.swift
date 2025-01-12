import SwiftUI

struct BadgeSendButton: View {
    @ObservedObject var badgeManager: LEDBadgeManager
    let messages: [Message]
    private var previewState: BadgeConnectionState?
    
    init(badgeManager: LEDBadgeManager, messages: [Message], previewState: BadgeConnectionState? = nil) {
        self.badgeManager = badgeManager
        self.messages = messages
        self.previewState = previewState
    }
    
    private var currentState: BadgeConnectionState {
        previewState ?? badgeManager.connectionState
    }
    
    var body: some View {
        HStack {
            if currentState != .ready && currentState != .error("") {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .controlSize(.small)
            }
            Button(action: {
                handleButtonPress()
            }) {
                HStack {
                    Text(currentState.buttonText)
                }
            }
            .disabled(
                currentState != .ready && currentState != .error(""))
        }
    }
    
    private func handleButtonPress() {
        switch currentState {
        case .ready, .error:
            badgeManager.connectAndSend(messages: messages)
        default:
            break
        }
    }
}

#Preview("Badge Send Button - All States") {
    VStack(spacing: 20) {
        ForEach([
            BadgeConnectionState.ready,
            .searching,
            .connecting,
            .sending,
            .error("Something went wrong")
        ], id: \.buttonText) { state in
            BadgeSendButton(
                badgeManager: LEDBadgeManager(),
                messages: [Message(flash: false, marquee: false, speed: .medium, mode: .left)],
                previewState: state
            )
        }
    }
    .padding()
}
