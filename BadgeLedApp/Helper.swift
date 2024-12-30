import AppKit

struct PixelData {
    let pixels: [[Pixel]]
    let width: Int
    let height: Int
}

func textToPixels(text: String, font: String, size: CGFloat) -> PixelData {
    guard let font = NSFont(name: font, size: size) else {
        print("Failed to load font: \(font)")
        return PixelData(pixels: [], width: 0, height: 0)
    }
    
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.black
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
        print("Failed to create bitmap")
        return PixelData(pixels: [], width: 0, height: 0)
    }
    
    bitmap.size = textSize
    NSGraphicsContext.saveGraphicsState()
    
    guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        print("Failed to create graphics context")
        return PixelData(pixels: [], width: 0, height: 0)
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
    
    // Ensure minimum height of 11 pixels
    let finalHeight = max(11, contentHeight)
    let extraRows = finalHeight - contentHeight
    
    // Create pixel array with the required height
    var pixelArray = Array(repeating: Array(repeating: Pixel(x: 0, y: 0, isOn: false), count: trimmedWidth), count: finalHeight)
    
    // Fill the array with actual content
    for y in 0..<contentHeight {
        for x in 0..<trimmedWidth {
            let sourceY = y + firstNonEmptyRow
            let sourceX = x + firstNonEmptyCol
            guard let color = bitmap.colorAt(x: sourceX, y: sourceY) else { continue }
            let brightness = color.brightnessComponent
            pixelArray[y][x] = Pixel(x: x, y: y, isOn: brightness < 0.5)
        }
    }
    
    // If we need extra rows, add them as empty rows
    if extraRows > 0 {
        for y in contentHeight..<finalHeight {
            for x in 0..<trimmedWidth {
                pixelArray[y][x] = Pixel(x: x, y: y, isOn: false)
            }
        }
    }
    
    return PixelData(
        pixels: pixelArray,
        width: trimmedWidth,
        height: finalHeight
    )
}
