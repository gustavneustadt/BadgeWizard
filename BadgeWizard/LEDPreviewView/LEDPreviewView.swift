//
// This View is inspired by the [Flutter App](https://github.com/fossasia/badgemagic-app) from FOSS ASIA and their Badge Preview
//
import SwiftUI
import Combine

struct LEDPreviewView: View {
    @ObservedObject var message: Message
    @State internal var currentPosition: Double = 0
    @State private var size: CGSize = .zero
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) var colorScheme

    @State internal var displayBuffer: DisplayBuffer
    
    
    init(message: Message?) {
        self.message = message ?? Message.placeholder()
        self._displayBuffer = State(initialValue: DisplayBuffer())
    }
    
    // Move computed properties here to make them reactive
    internal var pixels: [[Pixel]] {
        message.getCombinedPixelArrays()
    }
    
    // Hardware timing constants in microseconds
    private let BASE_SPEED: Double = 200000 // 0.2 seconds
    
    // Keep fast timer for smooth updates
    private let timer = Timer.publish(every: 0.025, on: .main, in: .common).autoconnect()
    
    internal var speedMultiplier: Double {
        let speedLevel = Double(message.speed.rawValue)
        // Calculate delay in microseconds using hardware formula
        let delayMicros = BASE_SPEED - (speedLevel * BASE_SPEED / 8.0)
        // Convert to seconds
        let delaySeconds = delayMicros / 1_000_000
        
        // Calculate pixels to move per frame
        // At slowest speed (0.2s delay) we want to move ~0.125 pixels per frame
        // At fastest speed (0.025s delay) we want to move ~1 pixel per frame
        return 0.025 / delaySeconds
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let ledSize = size.width / CGFloat(44)
                let ledSpacing = ledSize / 4
                
                if !isEnabled {
                    context.fill(
                        Path(roundedRect: CGRect(origin: .zero, size: size),
                             cornerRadius: (ledSize / 2) - ledSpacing),
                        with: .color(Color(nsColor: NSColor.separatorColor))
                    )
                    return
                }
                
                // Draw all LEDs in a single pass
                for y in 0..<11 {
                    for x in 0..<44 {
                        let isOn = displayBuffer.get(x, y)
                        let offset = CGSize(
                            width: CGFloat(x) * ledSize + ledSpacing / 2,
                            height: CGFloat(y) * ledSize + ledSpacing / 2
                        )
                        
                        context.translateBy(x: offset.width, y: offset.height)
                        context.fill(
                            Path(ellipseIn: CGRect(origin: .zero, size: CGSize(width: ledSize-2, height: ledSize-2))),
                            with: .color(isOn ? .accentColor : .accentColor.opacity(0.2))
                        )
                        context.translateBy(x: -offset.width, y: -offset.height)
                    }
                }
            }
            .shadow(color: .accentColor.opacity(1), radius: 3)
        }
        .frame(height: 11 * (size.width / 44))
        .getSize($size)
        .onReceive(timer) { _ in
                updateAnimation()
        }
        // Add onChange modifiers to handle property changes
        .onChange(of: message.pixelGrids) {
            currentPosition = 0  // Reset position when pixels change
        }
        .onChange(of: message.mode) {
            currentPosition = 0  // Reset position when mode changes
        }
    }
    
    private func updateAnimation() {
        // Update position with reactive multiplier
        currentPosition += speedMultiplier
        
        // Clear buffer instead of creating new one
        displayBuffer.clear()
        
        switch message.mode {
        case .left:
            scrollLeft()
        case .right:
            scrollRight()
        case .up:
            scrollUp()
        case .down:
            scrollDown()
        case .fixed:
            displayFixed()
        case .picture:
            displayPicture()
        case .snowflake:
            displaySnowflake()
        case .animation:
            displayAnimation()
        case .laser:
            displayLaser()
        }
        
        // Handle flash effect
        if message.flash && (Int(currentPosition / speedMultiplier) % 20) < 10 {
            displayBuffer.clear()
        }
        
        // Handle marquee effect if needed
        if message.marquee {
            applyMarquee()
        }
    }
}
