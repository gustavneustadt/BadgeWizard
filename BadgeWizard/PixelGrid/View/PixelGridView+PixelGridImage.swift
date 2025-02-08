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
        
        func iterateThroughLeds(grid: PixelGrid, maxWidth: Int? = nil, callback: (_ x: CGFloat, _ y: CGFloat, _ isOn: Bool) -> Void) {
            for y in 0..<grid.height {
                for x in 0..<min(maxWidth ?? grid.width, grid.width) {
                    callback(
                        CGFloat(x) * pixelSize,
                        CGFloat(y) * pixelSize,
                        grid.pixels[y][x]
                    )
                }
            }
        }
        
        var hoverPixelPosition: CGPoint? {
            var hoverPixel: CGPoint? = nil
            if let mousePosition = mousePosition {
                let x = Int((mousePosition.x - 2) / pixelSize)
                let y = Int((mousePosition.y - 2) / pixelSize)
                if x >= 0 && x < pixelGrid.width && y >= 0 && y < 11 {
                    hoverPixel = .init(
                        x: Double(x) * pixelSize,
                        y: Double(y) * pixelSize
                    )
                }
            }
            
            return hoverPixel
        }
        
        var body: some View {
            Canvas { context, size in
                
                var hoverPixelPath: Path = .init()
                var allOnionSkinItemsPath: Path = .init()
                var allItemsOnPath: Path = .init()
                var allItemsOffPath: Path = .init()
                
                iterateThroughLeds(
                    grid: pixelGrid
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
                
                if let grid = previousGrid {
                    iterateThroughLeds(
                        grid: grid,
                        maxWidth: pixelGrid.width
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
                
                guard hoverPixelPosition != nil else { return }
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
            .onChange(of: pixelSize, initial: true) {
                updatePaths()
            }
        }
    }
}
