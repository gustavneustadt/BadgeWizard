//
//  SettingsStore.swift
//  BadgeWizard
//
//  Created by Gustav on 27.01.25.
//
//
//  SettingsStore.swift
//  BadgeLedApp
//

import SwiftUI

// MARK: - Environment Key for Settings Store
private struct SettingsStoreKey: EnvironmentKey {
    static let defaultValue = SettingsStore.shared
}

extension EnvironmentValues {
    var settings: SettingsStore {
        get { self[SettingsStoreKey.self] }
        set { self[SettingsStoreKey.self] = newValue }
    }
}

/// Protocol defining the settings interface
protocol SettingsStoreProtocol {
    var pixelGridPixelSize: Double { get set }
}

/// Store for managing app-wide settings
final class SettingsStore: ObservableObject, SettingsStoreProtocol {
    /// Zoom level for the pixel grid display
    /// Default value is 1.0 (100%)
    @AppStorage("pixelGridPixelSize") var pixelGridPixelSize: Double = 20 {
        willSet { objectWillChange.send() }
    }
    
    /// Singleton instance for app-wide settings
    static let shared = SettingsStore()
    
    private init() {}
}

// MARK: - Constants
extension SettingsStore {
    /// Constants for zoom level limits and increments
    enum PixelGridPixelSizeLimits {
        static let minimum: Double = 10
        static let maximum: Double = 30
        static let increment: Double = 5
    }
}

// MARK: - Zoom Controls
extension SettingsStore {
    /// Increases the zoom level by one increment
    func increaseZoom() {
        let newSize = min(pixelGridPixelSize + PixelGridPixelSizeLimits.increment, PixelGridPixelSizeLimits.maximum)
        pixelGridPixelSize = newSize
    }
    
    /// Decreases the zoom level by one increment
    func decreaseZoom() {
        let newSize = max(pixelGridPixelSize - PixelGridPixelSizeLimits.increment, PixelGridPixelSizeLimits.minimum)
        pixelGridPixelSize = newSize
    }
    
    /// Resets the zoom level to 100%
    func resetZoom() {
        pixelGridPixelSize = 1.0
    }
}
