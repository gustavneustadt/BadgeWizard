//
//  Mode.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import Foundation
extension Message {
    /// Speed settings for LED badge animations
    /// Values represent different animation speeds from slowest to fastest
    enum Speed: Int, CaseIterable {
        case verySlow = 0   // Slowest
        case slow     = 1
        case relaxed  = 2
        case medium   = 3
        case steady   = 4
        case quick    = 5
        case fast     = 6
        case veryFast = 7   // Fastest
    }
    
    /// Animation modes for LED badge display
    enum Mode: Int, CaseIterable {
        case left      = 0
        case right     = 1
        case up        = 2
        case down      = 3
        case fixed     = 4
        case picture   = 5
        case snowflake = 6
        case animation = 7
        case laser     = 8
        
        var description: String {
            switch self {
            case .left:      return "Scroll Left"
            case .right:     return "Scroll Right"
            case .up:        return "Scroll Up"
            case .down:      return "Scroll Down"
            case .fixed:     return "Static Display"
            case .snowflake: return "Snowflake Effect"
            case .picture:   return "Picture Mode"
            case .animation: return "Wiper Animation"
            case .laser:     return "Laser Effect"
            }
        }
    }
}
