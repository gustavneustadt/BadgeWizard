//
//  PixelCanvas.swift
//  BadgeWizard
//
//  Created by Gustav on 13.02.25.
//

import SwiftUI

struct PixelCanvas: View {
    let pixels: [[Bool]]
    let pixelSize: CGFloat
    let itemPath: Path
    
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
            var allItemsOnPath: Path = .init()
            
            iterateThroughLeds(
                pixels: pixels
            ) { x, y, isOn in
                if isOn {
                    allItemsOnPath.addPath(
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
            let fillColor = Color.accentColor
#endif
            
            context.fill(
                allItemsOnPath,
                with: .color(
                    fillColor
                )
            )
        }
    }
}
