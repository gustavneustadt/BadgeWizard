//
//  PreviewSidebar.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//


import SwiftUI
import Combine

extension MessageView {
    struct PreviewSidebar: View {
        @ObservedObject var message: Message
        let previewTimer: Publishers.Autoconnect<Timer.TimerPublisher>
        var combinedPixel: [[Pixel]] {
            let _ = message.pixelGrids.map {
                $0.pixels
            }
            return message.getCombinedPixelArrays()
        }
        
        
        var body: some View {
            HStack(spacing: 0) {
                Divider()
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Preview")
                        LEDPreviewView(
                            message: message,
                            timer: previewTimer
                        )
                    }
                    
                    MessageFormView(
                        mode: $message.mode,
                        marquee: $message.marquee,
                        flash: $message.flash,
                        speed: $message.speed
                    )
                    Spacer()
                }
                .padding()
                .frame(maxWidth: 300)
            }
            .background(.thinMaterial)
        }
    }
}
