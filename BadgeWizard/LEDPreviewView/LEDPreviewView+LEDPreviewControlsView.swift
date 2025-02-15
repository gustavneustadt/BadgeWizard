//
//  LEDPreviewControlsView.swift
//  BadgeWizard
//
//  Created by Gustav on 07.02.25.
//

import SwiftUI

extension LEDPreviewView {
    
    struct LEDPreviewControlsView: View {
        @Binding var isPlaying: Bool
        var progress: Int
        var total: Int
        var onReset: () -> Void
        var onForwardFrame: () -> Void
        var onBackwardFrame: () -> Void
        @State var progressBarSize: CGSize = .zero
        
        func getDuration(_ totalSteps: Int) -> String {
            let value = 0.025 * Double(totalSteps)
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = value < 60 ? [.second] : [.minute, .second]
            formatter.allowsFractionalUnits = true
            formatter.unitsStyle = .short
            
            return formatter.string(from: value) ?? "\(value) seconds"
        }
        var totalAnimationDuration: String {
            getDuration(total)
        }
        
        var progressWidth: CGFloat {
            Double(progress) / Double(total) * progressBarSize.width
        }
        
        var body: some View {
                    VStack {
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(.secondary.opacity(0.2))
                                .frame(height: 2)
                            Rectangle()
                                .fill(.secondary.opacity(0.5))
                                .frame(width: progressWidth)
                                .frame(height: 2)
                                .animation(.linear(duration: 0.2), value: progressWidth)
                        }
                        .getSize($progressBarSize)
                        
                        HStack(alignment: .center) {
                            HStack {
                                Text(getDuration(progress))
                                    .textCase(.uppercase)
                                    .font(.footnote.monospacedDigit())
                                Spacer()
                            }
                            HStack {
                                Button {
                                    onBackwardFrame()
                                } label: {
                                    Image(systemName: "backward.frame.fill")
                                }
                                .buttonRepeatBehavior(.enabled)
                                Button {
                                    isPlaying.toggle()
                                } label: {
                                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                }
                                .frame(width: 20)
                                Button {
                                    onForwardFrame()
                                } label: {
                                    Image(systemName: "forward.frame.fill")
                                }
                                .buttonRepeatBehavior(.enabled)
                            }
                            .controlSize(.large)
                            HStack {
                                Spacer()
                                Text(getDuration(total))
                                    .textCase(.uppercase)
                                    .font(.footnote.monospacedDigit())
                            }
                        }
                        .foregroundStyle(.secondary)
                        .controlSize(.regular)
                        .buttonStyle(.borderless)
                        
                    }
                    .padding(.bottom, 16)
        }
    }
}
