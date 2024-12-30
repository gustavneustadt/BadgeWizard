import SwiftUI

struct Pixel: Identifiable, Hashable {
    let id = UUID()
    var x: Int
    var y: Int
    var isOn: Bool
}

class PixelGridViewModel: ObservableObject {
    @Published var pixels: [[Pixel]]
    @Published var width = 32 {
        didSet {
            buildMatrix()
        }
    }
    let height = 11
    
    // Add the gap property here
    @Published var patternGap: Int = 1
    
    init() {
        pixels = []
        for y in 0..<height {
            var row: [Pixel] = []
            for x in 0..<width {
                row.append(Pixel(x: x, y: y, isOn: false))
            }
            pixels.append(row)
        }
    }
    
    func stringToPixelGrid(text: String) {
        // Split the string into rows
        let rows = text.components(separatedBy: "\n")
        
        // Create the pixel grid
        var pixelGrid: [[Pixel]] = []
        
        // Process each row
        for (y, row) in rows.enumerated() {
            var pixelRow: [Pixel] = []
            
            // Process each character in the row
            for (x, char) in row.enumerated() {
                let pixel = Pixel(
                    x: x,
                    y: y,
                    isOn: (char == "O")
                )
                pixelRow.append(pixel)
            }
            
            // Only append non-empty rows to handle any trailing newlines
            if !pixelRow.isEmpty {
                pixelGrid.append(pixelRow)
            }
        }
        width = pixelGrid.isEmpty ? 0 : pixelGrid[0].count
        pixels = pixelGrid
    }
    
    func buildMatrix() {
        let oldPixels = pixels
        let oldWidth = oldPixels.isEmpty ? 0 : oldPixels[0].count
        
        // Create new matrix with updated width
        var newPixels: [[Pixel]] = []
        for y in 0..<height {
            var row: [Pixel] = []
            for x in 0..<width {
                if x < oldWidth && !oldPixels.isEmpty {
                    // Preserve existing pixel state
                    row.append(Pixel(x: x, y: y, isOn: oldPixels[y][x].isOn))
                } else {
                    // Add new pixel with default state
                    row.append(Pixel(x: x, y: y, isOn: false))
                }
            }
            newPixels.append(row)
        }
        
        pixels = newPixels
    }
    
    func setPixel(x: Int, y: Int, isOn: Bool) {
        pixels[y][x].isOn = isOn
    }
    
    func clearAll() {
        for y in 0..<height {
            for x in 0..<width {
                pixels[y][x].isOn = false
            }
        }
    }
    
    private func chunkToHex(startX: Int) -> String {
        var hexString = "" // Leading "00"
        var bytes: [UInt8] = Array(repeating: 0, count: 11) // Changed to 11 to match height
        
        for y in 0..<height {
            // Process 8 pixels in this row starting from startX
            for x in 0..<8 {
                let actualX = startX + x
                if actualX < width && pixels[y][actualX].isOn {
                    // For 90-degree counterclockwise rotation:
                    // - The x position becomes the bit position (y in the output)
                    // - The y position becomes the byte index from right to left
                    bytes[y] |= (1 << (7 - x))
                }
            }
        }
        
        // Convert bytes to hex
        for byte in bytes {
            hexString += String(format: "%02X", byte)
        }
        
        // hexString += "00" // Trailing "00"
        return hexString
    }
    
    // Convert all pixels to an array of hex strings
    func toHexStrings() -> [String] {
        var hexStrings: [String] = []
        
        // Process the grid in chunks of 8 pixels wide
        for startX in stride(from: 0, to: width, by: 8) {
            let chunk = chunkToHex(startX: startX)
            hexStrings.append(chunk)
        }
        
        return hexStrings
    }
}

// ASCII Art Import Extension
extension PixelGridViewModel {
    private func parseAsciiArt(_ input: String) -> [[Bool]] {
        let lines = input.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
        
        return lines.map { line in
            line.map { char in
                char == "0"
            }
        }
    }
    
    private func findFirstAvailablePosition(for pattern: [[Bool]]) -> (x: Int, y: Int)? {
        let patternWidth = pattern[0].count
        let patternHeight = pattern.count
        
        for y in 0...(height - patternHeight) {
            for x in 0...(width - patternWidth) {
                var canFit = true
                
                // Check the pattern area plus the gap area around it
                let startY = max(0, y - patternGap)
                let endY = min(height - 1, y + patternHeight + patternGap)
                let startX = max(0, x - patternGap)
                let endX = min(width - 1, x + patternWidth + patternGap)
                
                // Check if there are any active pixels in the expanded area
                for checkY in startY...endY {
                    for checkX in startX...endX {
                        if checkY >= y && checkY < y + patternHeight &&
                            checkX >= x && checkX < x + patternWidth {
                            continue
                        }
                        
                        if pixels[checkY][checkX].isOn {
                            canFit = false
                            break
                        }
                    }
                    if !canFit { break }
                }
                
                if canFit {
                    for py in 0..<patternHeight {
                        for px in 0..<patternWidth {
                            if pattern[py][px] && pixels[y + py][x + px].isOn {
                                canFit = false
                                break
                            }
                        }
                        if !canFit { break }
                    }
                }
                
                if canFit {
                    return (x, y)
                }
            }
        }
        
        return nil
    }
    
    private func placePattern(_ pattern: [[Bool]], at position: (x: Int, y: Int)) {
        for (y, row) in pattern.enumerated() {
            for (x, isOn) in row.enumerated() {
                if isOn {
                    pixels[position.y + y][position.x + x].isOn = true
                }
            }
        }
    }
    
    func importAsciiArt(_ input: String) {
        let pattern = parseAsciiArt(input)
        
        guard !pattern.isEmpty && !pattern[0].isEmpty else { return }
        
        guard pattern.count <= height && pattern[0].count <= width else {
            print("Pattern is too large for the grid")
            return
        }
        
        if let position = findFirstAvailablePosition(for: pattern) {
            placePattern(pattern, at: position)
        } else {
            print("No available space to place the pattern")
        }
    }
}

struct PixelEditorView: View {
    @ObservedObject var viewModel: PixelGridViewModel
    @State private var drawMode: Bool = true
    
    var body: some View {
        
        
        PixelGridImage(width: viewModel.width, pixels: viewModel.pixels)
            .frame(width: CGFloat(viewModel.width * 20),
                   height: CGFloat(11 * 20))
        .padding()
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let pixelSize: CGFloat = 20// 20px + 1px spacing
                    let padding: CGFloat = 15 // padding value
                    
                    let x = Int((value.location.x - padding) / pixelSize)
                    let y = Int((value.location.y - padding) / pixelSize)
                    
                    if x >= 0 && x < viewModel.width && y >= 0 && y < viewModel.height {
                        if value.translation == .zero {
                            // This is the start of the drag - set mode based on initial pixel
                            drawMode = !viewModel.pixels[y][x].isOn
                        }
                        viewModel.setPixel(x: x, y: y, isOn: drawMode)
                    }
                }
        )
    }
}

struct PixelView: View {
    let isOn: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(isOn ? Color.blue : Color.gray.opacity(0.3))
            .border(Color.black.opacity(0.2), width: 1)
    }
}

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
