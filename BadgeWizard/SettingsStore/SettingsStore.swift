//
//  SettingsStore.swift
//  BadgeWizard
//
//  Created by Gustav on 27.01.25.
//

import SwiftUI

/// Store for managing app-wide settings
class SettingsStore: ObservableObject {

    @AppStorage("pixelGridPixelSize") var pixelGridPixelSize: Double = 20 {
        willSet { objectWillChange.send() }
    }
    
    /// Singleton instance for app-wide settings
    static let shared = SettingsStore()
}




