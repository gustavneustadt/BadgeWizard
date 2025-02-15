//
// This View is inspired by the [Flutter App](https://github.com/fossasia/badgemagic-app) from FOSS ASIA and their Badge Preview
//
import SwiftUI
import SwiftData
import Combine

struct LEDPreviewView: View {
    let message: Message
    @State private var size: CGSize = .zero
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.appearsActive) private var appearsActive
    
    // MARK: Animation states
    @StateObject internal var displayBuffer: DisplayBuffer = DisplayBuffer()
    @State internal var timerStep: Int = 0
    @State internal var marqueeStep: Int = 0
    @State private var flashStep: Int = 0
    @State internal var animationStep: Int = 0
    @State var playAnimation: Bool = true
    @State var isInBackground: Bool = false
    
    // MARK: Shape drawing states
    @State var onPixelColor: Color = .accentColor
    @State var offPixelColor: Color = .accentColor.opacity(0.2)
    @State var onPixelShine: Color = .accentColor
    
    @State private var ledSize: CGFloat = 0
    @State private var ledSpacing: CGFloat = 0
    @State private var ledPath: Path = .init()
    
    init(message: Message?) {
        self.message = message ?? Message.placeholder()
    }
    
    var totalAnimationFrames: Int {
        let frames = { switch message.mode {
        case .up, .down:
            return getTotalStepsForVerticalScroll()
        case .left, .right:
            return getTotalStepsHorizontalScroll()
        case .animation:
            return getTotalStepsForAnimation()
        case .snowflake:
            return getTotalStepsForSnowflake()
        case .laser:
            return getTotalStepsForLaser()
        case .fixed:
            return getTotalStepsForFixedDisplay()
        case .picture:
            return getTotalStepsForPicture()
        }}()
        
        return max(1, frames)
    }
    
    var animationProgress: Double {
        guard pixels.isEmpty == false else {
            return 0
        }
        
        return Double(animationStep % totalAnimationFrames) / Double(totalAnimationFrames)
    }
    
    @State var pixels: [[Bool]] = [[]]
    
    func updateLedProperties() {
        self.ledSize = size.width / CGFloat(44)
        self.ledSpacing = ledSize / 4
        self.ledPath = Path(ellipseIn: CGRect(origin: .zero, size: CGSize(width: ledSize-2, height: ledSize-2)))
    }
    
    func updateLedColors() {
        let accentColor = Color.accentColor
        self.onPixelColor = {
            if appearsActive == false {
                return Color.secondary
            }
            
            return colorScheme == .dark ? accentColor.mix(with: .white, by: 0.5) : .accentColor
        }()
        
        self.offPixelColor = {
            if appearsActive == false {
                return Color.secondary.opacity(0.2)
            }
            return accentColor.opacity(0.2)
        }()
        
        self.onPixelShine = {
            if appearsActive == false {
                return accentColor.opacity(0)
            }
            return accentColor
        }()
    }
    
    func iterateThroughLeds(callback: (_ offsetX: CGFloat, _ offsetY: CGFloat, _ isOn: Bool) -> Void) {
        for y in 0..<11 {
            let offsetY: CGFloat = CGFloat(y) * ledSize + ledSpacing / 2
            for x in 0..<44 {
                let offsetX: CGFloat = CGFloat(x) * ledSize + ledSpacing / 2
                let isOn = displayBuffer.get(x, y)
                
                callback(offsetX, offsetY, isOn)
            }
        }
    }
    
    var updateAnimationAfterNumberOfSteps: Int {
        switch message.speed {
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
    }
    
    var isPaused: Bool {
        playAnimation == false || appearsActive == false
    }
    
    @State private var forceRedraw: UUID = UUID()
    
    var body: some View {
        VStack(spacing: 0) {
            TimelineView(.animation(minimumInterval: 0.025, paused: isPaused)) { timeline in
                ZStack {
                    Canvas { context, _ in
                        if !isEnabled {
                            context.fill(
                                Path(roundedRect: CGRect(origin: .zero, size: size),
                                     cornerRadius: (ledSize / 2) - ledSpacing),
                                with: .color(Color(nsColor: NSColor.separatorColor))
                            )
                            return
                        }
                        
                        var offPixelBatch = Path()
                        
                        iterateThroughLeds { x, y, isOn in
                            if isOn == false {
                                offPixelBatch.addPath(
                                    ledPath,
                                    transform: .init(translationX: x, y: y)
                                )
                            }
                        }
                        
                        context.fill(
                            offPixelBatch,
                            with: .color(offPixelColor)
                        )
                    }
                    Canvas { context, size in
                        guard isEnabled else { return }
                        
                        var onPixelBatch = Path()
                        
                        iterateThroughLeds { x, y, isOn in
                            if isOn {
                                onPixelBatch.addPath(
                                    ledPath,
                                    transform: .init(translationX: x, y: y)
                                )
                            }
                        }
                        
                        context.fill(
                            onPixelBatch,
                            with: .color(onPixelColor)
                        )
                    }
                    .shadow(color: onPixelShine, radius: 2)
                    .shadow(color: onPixelShine, radius: 5)
                    
                }
                .onChange(of: timeline.date) { _, _ in
                    timerStep += 1
                    updateAnimation()
                }
            }
            .id(forceRedraw)
            .frame(height: 11 * (size.width / 44))
            .getSize($size)
            
            ZStack(alignment: .center) {
                ProgressBar(
                    progress: (animationStep % totalAnimationFrames) * updateAnimationAfterNumberOfSteps,
                    total: totalAnimationFrames * updateAnimationAfterNumberOfSteps
                )
                
                LEDPreviewControlsView(
                    isPlaying: $playAnimation,
                    onReset: {
                        animationStep = 0
                        executeAnimationUpdate()
                        redraw()
                    },
                    onForwardFrame: {
                        animationStep += message.mode == .animation ? 5 : 1
                        executeAnimationUpdate()
                        redraw()
                    },
                    onBackwardFrame: {
                        let newAnimationStep = animationStep - (message.mode == .animation ? 5 : 1)
                        animationStep = newAnimationStep < 0 ? totalAnimationFrames : newAnimationStep
                        executeAnimationUpdate()
                        redraw()
                    })
                .padding(.top, 8)
            }
            .padding(.bottom)
        }
        .onChange(of: size) {
            updateLedProperties()
        }
        .onChange(of: pixels) {
            executeAnimationUpdate()
        }
        .onChange(of: message.mode) {
            animationStep = 0
            executeAnimationUpdate()
            redraw()
        }
        .onChange(of: colorScheme) { _, value in
            updateLedColors()
        }
        .onChange(of: appearsActive) {
            updateLedColors()
        }
        .onChange(of: message.forcePixelUpdate) {
            updatePixels()
        }
        .onAppear {
            updateLedColors()
            updatePixels()
            updateLedProperties()
        }
    }
    func updatePixels() {
        let grids: [[[Bool]]] = message.pixelGrids.map { grid in
            return grid.pixels
        }
        
        let newPixels = Message.combinePixelArrays(grids)
        pixels = newPixels
        
        if playAnimation == false {
            executeAnimationUpdate()
            redraw()
        }
        
    }
    
    func redraw() {
        forceRedraw = UUID()
    }
    
    fileprivate func executeAnimationUpdate() {
        // Increment by 1 since timer matches hardware timing
        guard pixels.isEmpty == false else {
            return
        }
        
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
        if timerStep % updateAnimationAfterNumberOfSteps == 0 {
            if playAnimation {
                animationStep += 1
            }
            executeAnimationUpdate()
        }
        
        if timerStep % 20 == 0 {
            flashStep += 1
        }
        
        if message.flash && (flashStep % 2 == 0) {
            displayBuffer.objectWillChange.send()
            displayBuffer.clear()
        }
        
        if timerStep % 4 == 0 {
            marqueeStep += 1
        }
        
        if message.marquee {
            displayBuffer.objectWillChange.send()
            applyMarquee()
        }
    }
}
