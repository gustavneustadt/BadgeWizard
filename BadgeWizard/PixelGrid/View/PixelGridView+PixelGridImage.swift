//
//  PixelGridImage.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//
import SwiftUI

extension PixelGridView {
    struct PixelGridImage: View {
        @ObservedObject var pixelGrid: PixelGrid
        var mousePosition: CGPoint? = nil
        
        var body: some View {
            Canvas { context, size in
                let pixelWidth: CGFloat = size.width / CGFloat(pixelGrid.width)
                let pixelHeight: CGFloat = size.height / 11
                
                // Create symbols
                guard let itemOn = context.resolveSymbol(id: "itemOn"),
                      let itemOff = context.resolveSymbol(id: "itemOff"),
                      let itemHover = context.resolveSymbol(id: "itemHover") else { return }
                
                var hoverPixel: (x: Int, y: Int)? = nil
                if let mousePosition = mousePosition {
                    let x = Int(mousePosition.x / pixelWidth)
                    let y = Int(mousePosition.y / pixelHeight)
                    if x >= 0 && x < pixelGrid.width && y >= 0 && y < 11 {
                        hoverPixel = (x, y)
                    }
                }
                
                let onPixels: [Pixel] = pixelGrid.pixels.compactMap { row in
                    row.compactMap { pixel in
                        pixel.isOn ? pixel : nil
                    }
                }.flatMap { $0 }
                
                for pixel in onPixels {
                    context.draw(
                        itemOn,
                        at: CGPoint(
                            x: CGFloat(pixel.x) * pixelWidth + pixelWidth/2,
                            y: CGFloat(pixel.y) * pixelHeight + pixelHeight/2
                        )
                    )
                }
                
                let offPixels: [Pixel] = pixelGrid.pixels.compactMap { row in
                    row.compactMap { pixel in
                        pixel.isOn == false ? pixel : nil
                    }
                }.flatMap { $0 }
                
                for pixel in offPixels {
                    context.draw(
                        itemOff,
                        at: CGPoint(
                            x: CGFloat(pixel.x) * pixelWidth + pixelWidth/2,
                            y: CGFloat(pixel.y) * pixelHeight + pixelHeight/2
                        )
                    )
                }
                
                // Draw hover effect if applicable
                if let hoverPixel = hoverPixel {
                    context.draw(
                        itemHover,
                        at: CGPoint(
                            x: CGFloat(hoverPixel.x) * pixelWidth + pixelWidth/2,
                            y: CGFloat(hoverPixel.y) * pixelHeight + pixelHeight/2
                        )
                    )
                }
                
            } symbols: {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color.accentColor)
                    .frame(width: 19, height: 19)
                    .tag("itemOn")
                
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(.separator)
                    .frame(width: 19, height: 19)
                    .tag("itemOff")
                
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(.separator)
                    .frame(width: 19, height: 19)
                    .tag("itemHover")
            }
        }
    }
}
