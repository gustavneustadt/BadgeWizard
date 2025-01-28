//
//  SettingsStore+Resize.swift
//  BadgeWizard
//
//  Created by Gustav on 28.01.25.
//

extension SettingsStore {
    func increaseSize() {
        let newSize = min(pixelGridPixelSize + PixelGridPixelSizeLimits.increment, PixelGridPixelSizeLimits.maximum)
        pixelGridPixelSize = newSize
    }
    
    func decreaseSize() {
        let newSize = max(pixelGridPixelSize - PixelGridPixelSizeLimits.increment, PixelGridPixelSizeLimits.minimum)
        pixelGridPixelSize = newSize
    }
}
