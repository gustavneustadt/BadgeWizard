//
//  PixelGridImage.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//
import SwiftUI

extension PixelGridView {
    struct PixelGridImage: View {
        var pixelGrid: PixelGrid
        var mousePosition: CGPoint? = nil
        var onionSkinning: Bool
        var previousGrid: PixelGrid?
        let pixelSize: CGFloat
        @Environment(\.colorScheme) var colorScheme
        
        init(pixelGrid: PixelGrid, mousePosition: CGPoint? = nil, onionSkinning: Bool? = false, pixelSize: CGFloat) {
            self.pixelGrid = pixelGrid
            self.mousePosition = mousePosition
            self.onionSkinning = onionSkinning ?? false
            self.pixelSize = pixelSize
            
            if  onionSkinning == true,
                let currentIndex = pixelGrid.getArrayIndex() ,
                currentIndex > 0 {
                self.previousGrid = pixelGrid.message?.pixelGrids[currentIndex - 1]
            }
        }
        
        func drawOnionSkin(context: GraphicsContext, symbol: GraphicsContext.ResolvedSymbol) {
            guard let previousGrid = self.previousGrid  else { return }
            guard let message = pixelGrid.message else { return }
            
            // Only draw onion skin if this isn't the first grid
            guard
                let currentIndex = message.pixelGrids.firstIndex(where: { $0.id == pixelGrid.id }),
                currentIndex > 0
            else { return }
            
            for y in 0..<previousGrid.height {
                for x in 0..<previousGrid.width {
                    guard x < pixelGrid.width else { continue }
                    guard previousGrid.pixels[y][x] == true else { continue }
                    context.draw(
                        symbol,
                        at: CGPoint(
                            x: CGFloat(x) * pixelSize + pixelSize/2,
                            y: CGFloat(y) * pixelSize + pixelSize/2
                        )
                    )
                }
            }
        }
        
        func drawHoverPixels(context: GraphicsContext, symbol: GraphicsContext.ResolvedSymbol) {
            var hoverPixel: (x: Int, y: Int)? = nil
            if let mousePosition = mousePosition {
                let x = Int((mousePosition.x - 2) / pixelSize)
                let y = Int((mousePosition.y - 2) / pixelSize)
                if x >= 0 && x < pixelGrid.width && y >= 0 && y < 11 {
                    hoverPixel = (x, y)
                }
            }
            
            // Draw hover effect if applicable
            if let hoverPixel = hoverPixel {
                context.draw(
                    symbol,
                    at: CGPoint(
                        x: CGFloat(hoverPixel.x) * pixelSize + pixelSize/2,
                        y: CGFloat(hoverPixel.y) * pixelSize + pixelSize/2
                    )
                )
            }
        }
        
        var body: some View {
            Canvas { context, size in
                // Create symbols
                guard let itemOn = context.resolveSymbol(id: "itemOn"),
                      let itemOff = context.resolveSymbol(id: "itemOff"),
                      let itemHover = context.resolveSymbol(id: "itemHover"),
                      let itemOnionSkin = context.resolveSymbol(id: "itemOnionSkin")
                else { return }
                
                for y in 0..<pixelGrid.height {
                    for x in 0..<pixelGrid.width {
                        context.draw(
                            pixelGrid.pixels[y][x] == true ? itemOn : itemOff,
                            at: CGPoint(
                                x: CGFloat(x) * pixelSize + pixelSize/2,
                                y: CGFloat(y) * pixelSize + pixelSize/2
                            )
                        )
                    }
                }
                
                drawHoverPixels(context: context, symbol: itemHover)
                drawOnionSkin(context: context, symbol: itemOnionSkin)
                
            } symbols: {
                RoundedRectangle(cornerRadius: pixelSize/8, style: .continuous)
                    .fill(Color.accentColor)
                    .frame(width: pixelSize - 2, height: pixelSize - 2)
                    .tag("itemOn")
                
                RoundedRectangle(cornerRadius: pixelSize/8, style: .continuous)
                    .fill(.separator)
                    .frame(width: pixelSize - 2, height: pixelSize - 2)
                    .tag("itemOff")
                
                RoundedRectangle(cornerRadius: pixelSize/8, style: .continuous)
                    .fill(.separator)
                    .frame(width: pixelSize - 2, height: pixelSize - 2)
                    .tag("itemHover")
                
                // Add onion skin symbol
                Circle()
                    .fill(Color.accentColor.mix(
                        with: colorScheme == .dark ? .black : .white,
                        by: colorScheme == .dark ? 0.7 : 0.4,
                        in: .perceptual
                    ).opacity(
                        colorScheme == .dark ? 0.6 : 0.8
                    ))
                    .frame(width: pixelSize / 2, height: pixelSize / 2)
                    .tag("itemOnionSkin")
            }
        }
    }
}
