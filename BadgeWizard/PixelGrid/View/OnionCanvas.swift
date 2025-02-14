//
//  OnionCanvas.swift
//  BadgeWizard
//
//  Created by Gustav on 13.02.25.
//

import SwiftUI

struct OnionCanvas: View {
    @Environment(\.colorScheme) var colorScheme
    let pixels: [[Bool]]
    let itemPath: Path
    let pixelSize: CGFloat
    
    func iterateThroughLeds(pixels: [[Bool]], maxWidth: Int? = nil, callback: (_ x: CGFloat, _ y: CGFloat, _ isOn: Bool) -> Void) {
        let firstRowCount = pixels.first?.count ?? 0
        for y in 0..<pixels.count {
            for x in 0..<min(maxWidth ?? firstRowCount, firstRowCount) {
                callback(
                    CGFloat(x) * pixelSize,
                    CGFloat(y) * pixelSize,
                    pixels[y][x]
                )
            }
        }
    }
    
    var body: some View {
        Canvas { context, size in
            
            var allOnionSkinItemsPath: Path = .init()
            iterateThroughLeds(
                pixels: pixels,
                maxWidth: pixels.first?.count ?? 0
            ) { x, y, isOn in
                if isOn {
                    allOnionSkinItemsPath.addPath(
                        itemPath,
                        transform:
                                .init(
                                    translationX: x,
                                    y: y
                                )
                    )
                }
            }
            
#if PIXELGRID_VIEW_DEBUG
            let fillColor = Color.init(hue: Double.random(in: 0...1), saturation: 0.5, brightness: 0.4)
#else
            let fillColor = Color.accentColor.mix(
                with: colorScheme == .dark ? .black : .white,
                by: colorScheme == .dark ? 0.7 : 0.4,
                in: .perceptual
            ).opacity(
                colorScheme == .dark ? 0.6 : 0.8
            )
#endif
            context.fill(
                allOnionSkinItemsPath,
                with: .color(
                    fillColor
                )
            )
        }
    }
}
