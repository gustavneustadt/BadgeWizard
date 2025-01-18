import SwiftUI

struct BadgeSendButton: View {
    @ObservedObject var badgeManager: LEDBadgeManager
    let messages: [Message]
    private var previewState: BadgeConnectionState?
    
    @State private var searchTimer: Timer?
    @State private var showCancelButton = false
    
    init(badgeManager: LEDBadgeManager, messages: [Message], previewState: BadgeConnectionState? = nil) {
        self.badgeManager = badgeManager
        self.messages = messages
        self.previewState = previewState
    }
    
    private var currentState: BadgeConnectionState {
        previewState ?? badgeManager.connectionState
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if currentState != .ready && currentState != .error("") {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .controlSize(.small)
            }
            
            Button(action: {
                handleButtonPress()
            }) {
                Text(currentState.buttonText)
            }
            .disabled(currentState != .ready && currentState != .error(""))
            
            if showCancelButton && currentState == .searching {
                Button(action: {
                    cancelSearch()
                }) {
                    Text("Cancel")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onChange(of: currentState) { _, newState in
            handleStateChange(newState)
        }
    }
    
    private func handleButtonPress() {
        switch currentState {
        case .ready, .error:
            badgeManager.connectAndSend(messages: messages)
            startSearchTimer()
        default:
            break
        }
    }
    
    private func startSearchTimer() {
        showCancelButton = false
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            if currentState == .searching {
                showCancelButton = true
            }
        }
    }
    
    private func cancelSearch() {
        badgeManager.stopScanning()
        badgeManager.connectionState = .ready
        searchTimer?.invalidate()
        searchTimer = nil
        showCancelButton = false
    }
    
    private func handleStateChange(_ newState: BadgeConnectionState) {
        if newState != .searching {
            searchTimer?.invalidate()
            searchTimer = nil
            showCancelButton = false
        }
    }
}

// Preview
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
