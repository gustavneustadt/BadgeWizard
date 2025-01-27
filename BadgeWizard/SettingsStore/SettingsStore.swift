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
    var zoomLevel: Double { get set }
}

/// Store for managing app-wide settings
final class SettingsStore: ObservableObject, SettingsStoreProtocol {
    /// Zoom level for the pixel grid display
    /// Default value is 1.0 (100%)
    @AppStorage("zoomLevel") var zoomLevel: Double = 1.0 {
        willSet { objectWillChange.send() }
    }
    
    /// Singleton instance for app-wide settings
    static let shared = SettingsStore()
    
    private init() {}
}

// MARK: - Constants
extension SettingsStore {
    /// Constants for zoom level limits and increments
    enum ZoomLimits {
        static let minimum: Double = 0.5  // 50%
        static let maximum: Double = 3.0  // 300%
        static let increment: Double = 0.25 // 25% steps
    }
}

// MARK: - Zoom Controls
extension SettingsStore {
    /// Increases the zoom level by one increment
    func increaseZoom() {
        let newZoom = min(zoomLevel + ZoomLimits.increment, ZoomLimits.maximum)
        zoomLevel = newZoom
    }
    
    /// Decreases the zoom level by one increment
    func decreaseZoom() {
        let newZoom = max(zoomLevel - ZoomLimits.increment, ZoomLimits.minimum)
        zoomLevel = newZoom
    }
    
    /// Resets the zoom level to 100%
    func resetZoom() {
        zoomLevel = 1.0
    }
}
