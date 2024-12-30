//
//  PixelGridImage.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//
import SwiftUI

struct PixelGridImage: View {
    let width: Int
    let pixels: [[Pixel]]
    
    var body: some View {
        Canvas { context, size in
            let pixelWidth: CGFloat = size.width / CGFloat(width)
            let pixelHeight: CGFloat = size.height / 11
            
            // Create symbol once and reuse
            guard let itemOn = context.resolveSymbol(id: "itemOn") else { return }
            guard let itemOff = context.resolveSymbol(id: "itemOff") else { return }
            
            for (y, row) in pixels.enumerated() {
                for (x, pixel) in row.enumerated() {
                    if pixel.isOn {
                        context.draw(
                            itemOn,
                            at: CGPoint(
                                x: CGFloat(x) * pixelWidth + pixelWidth/2,
                                y: CGFloat(y) * pixelHeight + pixelHeight/2
                            )
                        )
                    } else {
                        context.draw(
                            itemOff,
                            at: CGPoint(
                                x: CGFloat(x) * pixelWidth + pixelWidth/2,
                                y: CGFloat(y) * pixelHeight + pixelHeight/2
                            )
                        )
                    }
                }
            }
        } symbols: {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(Color.accentColor)
                .frame(width: 19, height: 19)
                .tag("itemOn")
            
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 19, height: 19)
                .tag("itemOff")
        }
    }
}
