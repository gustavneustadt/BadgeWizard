//
// This View is inspired by the [Flutter App](https://github.com/fossasia/badgemagic-app) from FOSS ASIA and their Badge Preview
//
import SwiftUI
import Combine

struct LEDPreviewView: View {
    @ObservedObject var message: Message
    @State private var size: CGSize = .zero
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) var colorScheme

    @State internal var displayBuffer: DisplayBuffer
    
    
    private var animationInterval: TimeInterval {
        let baseSpeed = 200000.0 / 1_000_000.0
        return baseSpeed - (Double(message.speed.rawValue) * baseSpeed / 8.0)
    }
    
    // Separate timers
    @State internal var currentPosition: Double = 0
    @State private var animationTimer: Timer.TimerPublisher = Timer.publish(every: 0.2, on: .main, in: .common)
    @State private var animationCancellable: AnyCancellable?
    
    @State internal var marqueeStep: Int = 0
    @State private var marqueeTimer: Timer.TimerPublisher = Timer.publish(every: 0.1, on: .main, in: .common)
    @State private var marqueeCancellable: AnyCancellable?
    
    @State private var flashStep: Int = 0
    @State private var flashTimer: Timer.TimerPublisher = Timer.publish(every: 0.5, on: .main, in: .common)
    @State private var flashCancellable: AnyCancellable?
    
    private func resetTimers() {
        // Cancel all existing timers
        animationCancellable?.cancel()
        marqueeCancellable?.cancel()
        flashCancellable?.cancel()
        
        // Start main animation timer
        animationTimer = Timer.publish(every: animationInterval, on: .main, in: .common)
        animationCancellable = AnyCancellable(animationTimer.connect())
        
        // Only start marquee timer if enabled
        if message.marquee {
            marqueeTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            marqueeCancellable = AnyCancellable(marqueeTimer.connect())
        }
        
        // Only start flash timer if enabled
        if message.flash {
            flashTimer = Timer.publish(every: 0.5, on: .main, in: .common)
            flashCancellable = AnyCancellable(flashTimer.connect())
        }
    }
    
    init(message: Message?) {
        self.message = message ?? Message.placeholder()
        self._displayBuffer = State(initialValue: DisplayBuffer())
    }
    
    // Move computed properties here to make them reactive
    internal var pixels: [[Pixel]] {
        message.getCombinedPixelArrays()
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
        .onChange(of: message.speed) { resetTimers() }
        .onChange(of: message.marquee) { resetTimers() }
        .onChange(of: message.flash) { resetTimers() }
        .onReceive(animationTimer) { _ in updateAnimation() }
        .onReceive(marqueeTimer) { _ in marqueeStep += 1 }
        .onReceive(flashTimer) { _ in flashStep += 1 }
        .onAppear { resetTimers() }
        .onDisappear {
            animationCancellable?.cancel()
            marqueeCancellable?.cancel()
            flashCancellable?.cancel()
        }
        .onChange(of: message.mode) {
            currentPosition = 0
        }
    }
    
    private func updateAnimation() {
        currentPosition += 1  // Increment by 1 since timer matches hardware timing
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
        
        if message.flash && (flashStep % 2 == 0) {
            displayBuffer.clear()
        }
        
        if message.marquee {
            applyMarquee()
        }
    }
}
