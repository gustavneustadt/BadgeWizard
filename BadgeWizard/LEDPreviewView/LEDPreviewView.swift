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
    
    @State internal var timerStep: Int = 0
    @State internal var marqueeStep: Int = 0
    @State private var flashStep: Int = 0
    @State internal var animationStep: Int = 0
    
    let animationTimer = Timer.publish(every: 0.025, on: .main, in: .common).autoconnect()
    
    init(message: Message?) {
        self.message = message ?? Message.placeholder()
        self._displayBuffer = State(initialValue: DisplayBuffer())
    }
    
    internal var pixels: [[Pixel]] {
        message.getCombinedPixelArrays()
    }
    
    let offPixelColor: Color = .accentColor.opacity(0.2)
    let onPixelColor: Color = .accentColor.mix(with: .white, by: 0.5)
    var body: some View {
        TimelineView(.animation) { timeline in
            ZStack {
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
                    
                    let ledPath = Path(ellipseIn: CGRect(origin: .zero, size: CGSize(width: ledSize-2, height: ledSize-2)))
                    // Draw all LEDs in a single pass
                    
                    var offPixelBatch = Path()
                    
                    for y in 0..<11 {
                        let offsetY: CGFloat = CGFloat(y) * ledSize + ledSpacing / 2
                        for x in 0..<44 {
                            let offsetX: CGFloat = CGFloat(x) * ledSize + ledSpacing / 2
                            let isOn = displayBuffer.get(x, y)
                            guard !isOn else { continue }
                            
                            offPixelBatch.addPath(
                                ledPath,
                                transform:
                                        .init(translationX: offsetX, y: offsetY)
                            )
                        }
                    }
                    
                    context.fill(
                        offPixelBatch,
                        with: .color(offPixelColor)
                    )
                }
                Canvas { context, size in
                    let ledSize = size.width / CGFloat(44)
                    let ledSpacing = ledSize / 4
                    
                    guard isEnabled else { return }
                    
                    let ledPath = Path(ellipseIn: CGRect(origin: .zero, size: CGSize(width: ledSize-2, height: ledSize-2)))
                    // Draw all LEDs in a single pass
                    
                    var onPixelBatch = Path()
                    
                    for y in 0..<11 {
                        let offsetY: CGFloat = CGFloat(y) * ledSize + ledSpacing / 2
                        for x in 0..<44 {
                            let offsetX: CGFloat = CGFloat(x) * ledSize + ledSpacing / 2
                            let isOn = displayBuffer.get(x, y)
                            guard isOn else { continue }
                            
                            onPixelBatch.addPath(
                                ledPath,
                                transform:
                                        .init(translationX: offsetX, y: offsetY)
                            )
                        }
                    }
                    
                    context.fill(
                        onPixelBatch,
                        with: .color(onPixelColor)
                    )
                }
                .shadow(color: .accentColor, radius: 2)
                .shadow(color: .accentColor, radius: 5)
            }
        }
        .frame(height: 11 * (size.width / 44))
        .getSize($size)
        .onReceive(animationTimer) { _ in updateAnimation() }
        .onChange(of: pixels) {
            executeAnimationUpdate()
        }
        .onChange(of: message.mode) {
            animationStep = 0
        }
    }
    
    fileprivate func executeAnimationUpdate() {
        // Increment by 1 since timer matches hardware timing
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
    }
    
    private func updateAnimation() {
        timerStep += 1
        
        let nthUpdate: Int = { switch message.speed {
        case .verySlow:
            8
        case .slow:
            7
        case .relaxed:
            6
        case .medium:
            5
        case .steady:
            4
        case .quick:
            3
        case .fast:
            2
        case .veryFast:
            1
        }
        }()
        
        if timerStep % nthUpdate == 0 {
            animationStep += 1
            executeAnimationUpdate()
        }
        
        if timerStep % 20 == 0 {
            flashStep += 1
        }
        
        if message.flash && (flashStep % 2 == 0) {
            displayBuffer.clear()
        }
        
        if timerStep % 4 == 0 {
            marqueeStep += 1
        }
        
        if message.marquee {
            applyMarquee()
        }
    }
}
