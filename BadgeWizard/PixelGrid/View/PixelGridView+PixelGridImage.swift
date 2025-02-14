//
//  PixelGridImage.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//
import SwiftUI

extension PixelGridView {
    struct PixelGridImage: View {
        let pixels: [[Bool]]
        let onionPixels: [[Bool]]
        let pixelSize: CGFloat
        @Environment(\.colorScheme) var colorScheme
        @State var hoverPixel: (x: Int, y: Int)? = nil
        // let hoverPixel: (x: Int, y: Int)?
        
        func calculateHoverPixel(_ point: CGPoint?) {
            var hoverPixel: (x: Int, y: Int)? = nil
            if let point = point {
                let x = Int((point.x - 2) / pixelSize)
                let y = Int((point.y - 2) / pixelSize)
                hoverPixel = (x: x, y: y)
            }
            
            self.hoverPixel = hoverPixel
        }
        
        
        func updatePaths() {
            let itemSize = pixelSize - 2
            let onionOffset = pixelSize / 4
            let onionSize = pixelSize / 2
            let itemRadius = round(pixelSize/8)
            
            self.itemPath =
            RoundedRectangle(cornerRadius: itemRadius, style: .circular)
                .path(in:
                        .init(
                            x: 1, y: 1,
                            width: itemSize, height: itemSize
                        )
                )
            
            self.onionSkinPath =
            Circle().path(in:
                    .init(
                        x: onionOffset, y: onionOffset,
                        width: onionSize, height: onionSize
                    )
            )
        }
        
        @State var itemPath: Path = .init()
        @State var onionSkinPath: Path = .init()
        
        
        init(pixels: [[Bool]], onionPixels: [[Bool]], pixelSize: CGFloat, hoverPixel: (x: Int, y: Int)?) {
            self.pixels = pixels
            self.onionPixels = onionPixels
            self.pixelSize = pixelSize
            self.hoverPixel = hoverPixel
        }
        
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
        
        var hoverPixelPosition: CGPoint? {
            guard hoverPixel != nil else { return nil }
            let firstRowCount = pixels.first?.count ?? 0
            if hoverPixel!.x >= 0 && hoverPixel!.x < firstRowCount && hoverPixel!.y >= 0 && hoverPixel!.y < 11 {
                return .init(
                    x: Double(hoverPixel!.x) * pixelSize,
                    y: Double(hoverPixel!.y) * pixelSize
                )
            }
            
            return nil
        }
        
        var body: some View {
            ZStack {
                OffPixelCanvas(height: pixels.count, width: pixels.first?.count ?? 0, itemPath: itemPath, pixelSize: pixelSize)
                PixelCanvas(pixels: pixels, pixelSize: pixelSize, itemPath: itemPath)
                OnionCanvas(pixels: onionPixels, itemPath: onionSkinPath, pixelSize: pixelSize)
                if hoverPixelPosition != nil {
                    HoverCanvas(hoverPixelPosition: hoverPixelPosition!, itemPath: itemPath)
                }
            }
            .onContinuousHover(coordinateSpace: .local, perform: { phase in
                switch phase {
                case .active(let pt):
                    calculateHoverPixel(pt)
                    return
                case .ended:
                    hoverPixel = nil
                }
            })
            .onChange(of: pixelSize, initial: true) {
                updatePaths()
            }
        }
    }
}
