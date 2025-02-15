//
//  HoverCanvas.swift
//  BadgeWizard
//
//  Created by Gustav on 13.02.25.
//

import SwiftUI
extension PixelGridView {
    struct HoverCanvas: View {
        let hoverPixelPosition: CGPoint
        let itemPath: Path
        var body: some View {
            Canvas { context, size in
                var hoverPixelPath: Path = .init()
                hoverPixelPath.addPath(
                    itemPath,
                    transform:
                            .init(
                                translationX: hoverPixelPosition.x,
                                y: hoverPixelPosition.y
                            )
                )
                context.fill(
                    hoverPixelPath,
                    with: .color(
                        Color(nsColor: NSColor.separatorColor)
                    )
                )
            }
        }
    }
}
