//
//  OffPixelCanvas.swift
//  BadgeWizard
//
//  Created by Gustav on 13.02.25.
//

import SwiftUI

struct OffPixelCanvas: View {
    let height: Int
    let width: Int
    let itemPath: Path
    let pixelSize: CGFloat
    
    var body: some View {
        Canvas { context, size in
            var allItemsOffPath: Path = .init()
            for y in 0..<height {
                for x in 0..<width {
                    allItemsOffPath.addPath(
                        itemPath,
                        transform:
                                .init(
                                    translationX: Double(x) * pixelSize,
                                    y: Double(y) * pixelSize
                                )
                    )
                }
            }
#if PIXELGRID_VIEW_DEBUG
            let fillColor = Color.init(hue: Double.random(in: 0...1), saturation: 0.5, brightness: 0.4)
#else
            let fillColor = Color(nsColor: NSColor.separatorColor)
#endif
            
            context.fill(
                allItemsOffPath,
                with: .color(
                    fillColor
                )
            )
        }
    }
}
