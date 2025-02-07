import AppKit
extension PixelGrid {
    
    func createFontWithPostscript(postscriptName: String, size: CGFloat) -> NSFont? {
        return NSFont(name: postscriptName, size: size)
    }
    
    func applyText(_ text: String, postscriptFontName: String, size: CGFloat = 11, kerning: CGFloat = 0) {
        guard let font = createFontWithPostscript(postscriptName: postscriptFontName, size: size) else {
            print("Failed to load font: \(postscriptFontName)")
            return
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .ligature: 2,
            .foregroundColor: NSColor.black,
            .kern: kerning
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()
        
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(ceil(textSize.width)),
            pixelsHigh: Int(ceil(textSize.height)),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            
            self.update(pixels: [[]], width: 1)
            
            print("Failed to create bitmap")
            return
        }
        
        bitmap.size = textSize
        NSGraphicsContext.saveGraphicsState()
        
        guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
            self.update(pixels: [[]], width: 1)
            print("Failed to create graphics context")
            return
        }
        NSGraphicsContext.current = context
        
        NSColor.white.set()
        NSRect(origin: .zero, size: textSize).fill()
        
        let rect = NSRect(origin: .zero, size: textSize)
        attributedString.draw(with: rect, options: [.usesLineFragmentOrigin])
        
        NSGraphicsContext.restoreGraphicsState()
        
        let height = Int(textSize.height)
        let width = Int(textSize.width)
        
        var firstNonEmptyRow = height
        var lastNonEmptyRow = 0
        var firstNonEmptyCol = width
        var lastNonEmptyCol = 0
        
        // Find content bounds
        for y in 0..<height {
            var rowHasContent = false
            for x in 0..<width {
                guard let color = bitmap.colorAt(x: x, y: y) else { continue }
                let brightness = color.brightnessComponent
                if brightness < 0.5 {
                    firstNonEmptyRow = min(firstNonEmptyRow, y)
                    lastNonEmptyRow = max(lastNonEmptyRow, y)
                    firstNonEmptyCol = min(firstNonEmptyCol, x)
                    lastNonEmptyCol = max(lastNonEmptyCol, x)
                    rowHasContent = true
                }
            }
            if rowHasContent && firstNonEmptyRow == height {
                firstNonEmptyRow = y
            }
        }
        
        let contentHeight = lastNonEmptyRow - firstNonEmptyRow + 1
        let trimmedWidth = lastNonEmptyCol - firstNonEmptyCol + 1
        
        // Calculate how many rows we'll actually use (max 11)
        let finalHeight = 11
        let rowsToUse = max(min(contentHeight, finalHeight), 0)
        
        var pixelArray = Array(repeating: Array(repeating: false, count: trimmedWidth < 1 ? 1 : trimmedWidth), count: finalHeight)
        
        // Fill the array with actual content (up to 11 rows)
        for y in 0..<rowsToUse {
            for x in 0..<trimmedWidth {
                let sourceY = y + firstNonEmptyRow
                let sourceX = x + firstNonEmptyCol
                guard let color = bitmap.colorAt(x: sourceX, y: sourceY) else { continue }
                let brightness = color.brightnessComponent
                pixelArray[y][x] = brightness < 0.5
            }
        }
        
        guard trimmedWidth > 0 else {
            self.update(pixels: [[]], width: 1)
            return
        }
        
        // If we need extra rows to reach 11, add them as empty rows
        if rowsToUse < finalHeight {
            for y in rowsToUse..<finalHeight {
                for x in 0..<trimmedWidth {
                    pixelArray[y][x] = false
                }
            }
        }
        self.update(pixels: pixelArray, width: trimmedWidth)
    }
}
