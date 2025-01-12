//
//  BadgeConnectionState.swift
//  BadgeLedApp
//
//  Created by Gustav on 31.12.24.
//


enum BadgeConnectionState: Equatable {
    case ready          // Initial state, ready to start
    case searching      // Looking for the badge
    case connecting    // Found badge, establishing connection
    case sending       // Connected, sending data
    case error(String) // Error occurred, contains error message
    
    var buttonText: String {
        switch self {
        case .ready:      return "Send to Badge"
        case .searching:  return "Searching..."
        case .connecting: return "Connecting..."
        case .sending:    return "Sending..."
        case .error:      return "Retry"
        }
    }
    
    // Add custom equality comparison for the error case
    static func == (lhs: BadgeConnectionState, rhs: BadgeConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.ready, .ready),
            (.searching, .searching),
            (.connecting, .connecting),
            (.sending, .sending):
            return true
        case let (.error(lhsMessage), .error(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}