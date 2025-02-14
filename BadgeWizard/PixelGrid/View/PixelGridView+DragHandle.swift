//
//  PixelGridView+DragHandle.swift
//  BadgeWizard
//
//  Created by Gustav on 19.01.25.
//

import SwiftUI

extension PixelGridView {
    struct DragHandle: View {
        let pixelSize: CGFloat
        @State var hovering: Bool = false
        
        var body: some View {
            Canvas { context, size in
                // Draw background
                let backgroundPath = Path { path in
                    path.addPath(
                        UnevenRoundedRectangle(
                            cornerRadii: .init(
                                topLeading: pixelSize/8,
                                bottomLeading: pixelSize/8,
                                bottomTrailing: pixelSize/2,
                                topTrailing: pixelSize/2
                            )
                        ).path(in: CGRect(origin: .zero, size: size))
                    )
                }
                
                context.fill(
                    backgroundPath,
                    with: .color(
                        Color(nsColor: .separatorColor)
                    )
                )
                if hovering {
                    context.fill(
                        backgroundPath,
                        with: .color(
                            Color(nsColor: .separatorColor)
                        )
                    )
                }
                
                // Draw lines
                let lineHeight: CGFloat = pixelSize * 1.66
                let lineSpacing: CGFloat = pixelSize / 8
                let startY = (size.height - lineHeight) / 2
                let startX = (size.width - (3 + lineSpacing * 2)) / 2
                
                context.stroke(
                    Path { path in
                        for i in 0..<3 {
                            let x = startX + CGFloat(i) * (1 + lineSpacing)
                            path.move(to: CGPoint(x: x, y: startY))
                            path.addLine(to: CGPoint(x: x, y: startY + lineHeight))
                        }
                    },
                    with: .color(.primary.opacity(0.4)),
                    lineWidth: 1
                )
            }
            .frame(width: pixelSize - 1, height: 3 * pixelSize - 2)
            .shadow(radius: 1, x: 0, y: 0)
            .onHover { hovering in
                self.hovering = hovering
            }
        }
    }
}
