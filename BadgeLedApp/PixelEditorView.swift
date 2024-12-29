import SwiftUI

struct Pixel: Identifiable {
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
        
        // Process each row (11 pixels high)
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

struct PixelEditorView: View {
    @ObservedObject var viewModel: PixelGridViewModel
    @State private var drawMode: Bool = true  // true = drawing, false = erasing
    
    var body: some View {
                ScrollView([.horizontal]) {
                    VStack(spacing: 1) {
                        ForEach(0..<viewModel.height, id: \.self) { y in
                            HStack(spacing: 1) {
                                ForEach(0..<viewModel.width, id: \.self) { x in
                                    PixelView(isOn: viewModel.pixels[y][x].isOn)
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                    }
                    .padding()
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let pixelSize: CGFloat = 21 // 20px + 1px spacing
                                let padding: CGFloat = 16   // padding value
                                
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
            .frame(maxHeight: 400)
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


extension PixelGridViewModel {
    // Convert ASCII art string to 2D boolean array
    private func parseAsciiArt(_ input: String) -> [[Bool]] {
        let lines = input.components(separatedBy: .newlines)
        
        return lines.map { line in
            line.map { char in
                char == "0" // true for '0', false for any other character
            }
        }
    }
    
    // Find the first available position where the pattern can fit
    private func findFirstAvailablePosition(for pattern: [[Bool]]) -> (x: Int, y: Int)? {
        let patternWidth = pattern[0].count
        let patternHeight = pattern.count
        
        // Check each possible position in the grid
        for y in 0...(height - patternHeight) {
            for x in 0...(width - patternWidth) {
                var canFit = true
                
                // Check if the pattern can fit at this position
                // without overlapping existing pixels
                for py in 0..<patternHeight {
                    for px in 0..<patternWidth {
                        if pattern[py][px] && pixels[y + py][x + px].isOn {
                            canFit = false
                            break
                        }
                    }
                    if !canFit { break }
                }
                
                if canFit {
                    return (x, y)
                }
            }
        }
        
        return nil
    }
    
    // Place the pattern at the specified position
    private func placePattern(_ pattern: [[Bool]], at position: (x: Int, y: Int)) {
        for (y, row) in pattern.enumerated() {
            for (x, isOn) in row.enumerated() {
                if isOn {
                    pixels[position.y + y][position.x + x].isOn = true
                }
            }
        }
    }
    
    // Main function to import ASCII art
    func importAsciiArt(_ input: String) {
        let pattern = parseAsciiArt(input)
        
        // Validate pattern
        guard !pattern.isEmpty && !pattern[0].isEmpty else { return }
        
        // Check if pattern can fit in the grid
        guard pattern.count <= height && pattern[0].count <= width else {
            print("Pattern is too large for the grid")
            return
        }
        
        // Find position and place pattern
        if let position = findFirstAvailablePosition(for: pattern) {
            placePattern(pattern, at: position)
        } else {
            print("No available space to place the pattern")
        }
    }
}
