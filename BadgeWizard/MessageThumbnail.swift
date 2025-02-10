//
//  MessageThumbnail.swift
//  BadgeWizard
//
//  Created by Gustav on 10.02.25.
//
import SwiftUI

/// A simplified LED preview view specifically for thumbnail generation
private struct ThumbnailPreviewView: View {
    let message: Message
    let step: Int
    @State private var size: CGSize = .zero
    private let displayBuffer = DisplayBuffer()
    
    private var ledSize: CGFloat {
        size.width / CGFloat(44)
    }
    
    private var ledSpacing: CGFloat {
        ledSize / 4
    }
    
    private var ledPath: Path {
        Path(CGRect(origin: .zero, size: CGSize(width: ledSize, height: ledSize)))
    }
    
    var body: some View {
        Canvas { context, _ in
            var offPixelBatch = Path()
            var onPixelBatch = Path()
            
            // Prepare the display buffer
            displayBuffer.clear()
            renderScrollFrame(step: step)
            
            // Draw LEDs
            for y in 0..<11 {
                let offsetY: CGFloat = CGFloat(y) * ledSize
                for x in 0..<44 {
                    let offsetX: CGFloat = CGFloat(x) * ledSize
                    let isOn = displayBuffer.get(x, y)
                    
                    let ledPathWithOffset = ledPath.applying(
                        .init(translationX: offsetX, y: offsetY)
                    )
                    
                    if isOn {
                        onPixelBatch.addPath(ledPathWithOffset)
                    } else {
                        offPixelBatch.addPath(ledPathWithOffset)
                    }
                }
            }
            
            // Draw all off pixels
            context.fill(
                offPixelBatch,
                with: .color(.accentColor.opacity(0.2))
            )
            
            // Draw all on pixels
            context.fill(
                onPixelBatch,
                with: .color(.accentColor)
            )
        }
        .frame(height: 11 * (size.width / 44))
        .getSize($size)
    }
    
    private func renderScrollFrame(step: Int) {
        let badgeWidth = 44
        let pixels = message.getCombinedPixelArrays()
        let totalWidth = pixels[0].count
        
        // Draw the current frame
        for y in 0..<11 {
            for x in 0..<badgeWidth {
                // Calculate source position accounting for scroll
                let sourceX = x + step - badgeWidth
                
                // Only draw if we're within bounds of source pixels
                if sourceX >= 0 && sourceX < totalWidth {
                    displayBuffer.set(x, y, pixels[y][sourceX])
                }
            }
        }
    }
}

actor ThumbnailActor {
    private var cache: [UUID: MessageThumbnail] = [:]
    
    func getThumbnail(for message: Message, size: CGSize) async -> MessageThumbnail? {
        // Check cache first
        if let cached = cache[message.id] {
            return cached
        }
        
        // Generate thumbnail in background
        let thumbnail = await Task.detached(priority: .background) {
            await MainActor.run {
                var frames: [CGImage] = []
                let badgeWidth = 44
                let totalWidth = message.getCombinedPixelArrays()[0].count
                let totalSteps = totalWidth + badgeWidth
                
                for step in 0..<totalSteps {
                    let renderer = ImageRenderer(content:
                                                    ThumbnailPreviewView(message: message, step: step)
                        .frame(width: size.width)
                    )
                    
                    if let cgImage = renderer.cgImage {
                        frames.append(cgImage)
                    }
                }
                
                return MessageThumbnail(frames: frames)
            }
        }.value
        
        // Cache the result
        cache[message.id] = thumbnail
        return thumbnail
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

@MainActor
class ThumbnailGenerator: ObservableObject {
    private let actor = ThumbnailActor()
    
    func getThumbnail(for message: Message, size: CGSize) async -> MessageThumbnail? {
        await actor.getThumbnail(for: message, size: size)
    }
    
    func clearCache() async {
        await actor.clearCache()
    }
}

struct MessageThumbnail {
    let frames: [CGImage]
}

struct MessageListItem: View {
    let message: Message
    let thumbnailGenerator: ThumbnailGenerator
    
    @State private var currentFrame: Int = 0
    @State private var timerStep: Int = 0
    @State private var thumbnail: MessageThumbnail?
    let timer = Timer.publish(every: 0.025, on: .main, in: .common)
    
    var updateAnimationAfterNumberOfSteps: Int {
        switch message.speed {
        case .verySlow: return 8
        case .slow: return 7
        case .relaxed: return 6
        case .medium: return 5
        case .steady: return 4
        case .quick: return 3
        case .fast: return 2
        case .veryFast: return 1
        }
    }
    
    var body: some View {
        HStack {
            if let thumbnail = thumbnail {
                Image(thumbnail.frames[currentFrame], scale: 1.0, label: Text("Message Preview"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
            } else {
                ProgressView()
                    .frame(width: 100, height: 25)
                    .controlSize(.small)
            }
            
            VStack(alignment: .leading) {
                Text("Message \(message.id.uuidString.prefix(8))")
                    .font(.headline)
                Text("\(message.pixelGrids.count) grids")
                    .font(.subheadline)
            }
        }
        .task {
            // thumbnail = await thumbnailGenerator.getThumbnail(
            //     for: message,
            //     size: CGSize(width: 100, height: 25)
            // )
        }
        .onReceive(timer) { _ in
            guard let thumbnail = thumbnail else { return }
            
            timerStep += 1
            if timerStep % updateAnimationAfterNumberOfSteps == 0 {
                currentFrame = (currentFrame + 1) % thumbnail.frames.count
            }
        }
    }
}

struct MessageListView: View {
    let messages: [Message]
    @StateObject private var thumbnailGenerator = ThumbnailGenerator()
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        List(messages, id: \.id) { message in
            MessageListItem(message: message, thumbnailGenerator: thumbnailGenerator)
                .onTapGesture(count: 2) {
                        openWindow(value: message)
                    }
        }
    }
}
