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
        @State var hoverPixel: (x: Int, y: Int)?
        
        @State var mousePosition: CGPoint? = nil
        @Environment(\.colorScheme) var colorScheme
        
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
            RoundedRectangle(cornerRadius: itemRadius, style: .continuous)
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
        
        
        init(pixels: [[Bool]], onionPixels: [[Bool]], pixelSize: CGFloat) {
            self.pixels = pixels
            self.onionPixels = onionPixels
            self.pixelSize = pixelSize
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
                
                Canvas { context, size in
                    
                    var allOnionSkinItemsPath: Path = .init()
                    var allItemsOnPath: Path = .init()
                    var allItemsOffPath: Path = .init()
                    
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
                        } else {
                            allItemsOffPath.addPath(
                                itemPath,
                                transform:
                                        .init(
                                            translationX: x,
                                            y: y
                                        )
                            )
                        }
                    }
                    
                    if let pixels = onionPixels.count > 0 ? onionPixels : nil {
                        iterateThroughLeds(
                            pixels: pixels,
                            maxWidth: pixels.first?.count ?? 0
                        ) { x, y, isOn in
                            if isOn {
                                allOnionSkinItemsPath.addPath(
                                    onionSkinPath,
                                    transform:
                                            .init(
                                                translationX: x,
                                                y: y
                                            )
                                )
                            }
                        }
                    }
                    
                    context.fill(
                        allItemsOffPath,
                        with: .color(
                            Color(nsColor: NSColor.separatorColor)
                        )
                    )
                    context.fill(
                        allItemsOnPath,
                        with: .color(
                            Color.accentColor
                        )
                    )
                    context.fill(
                        allOnionSkinItemsPath,
                        with: .color(
                            Color.accentColor.mix(
                                with: colorScheme == .dark ? .black : .white,
                                by: colorScheme == .dark ? 0.7 : 0.4,
                                in: .perceptual
                            ).opacity(
                                colorScheme == .dark ? 0.6 : 0.8
                            )
                        )
                    )
                }
                if hoverPixelPosition != nil {
                    Canvas { context, size in
                        var hoverPixelPath: Path = .init()
                        hoverPixelPath.addPath(
                            itemPath,
                            transform:
                                    .init(
                                        translationX: hoverPixelPosition!.x,
                                        y: hoverPixelPosition!.y
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
            
            .border(Color.init(hue: Double.random(in: 0...1), saturation: 0.5, brightness: 0.4))
            
            .onChange(of: pixelSize, initial: true) {
                updatePaths()
            }
            .onContinuousHover(coordinateSpace: .local, perform: { phase in
                switch phase {
                case .active(let pt):
                    calculateHoverPixel(pt)
                case .ended:
                    hoverPixel = nil
                }
            })
        }
    }
}
