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
        var onReset: () -> Void
        var onForwardFrame: () -> Void
        var onBackwardFrame: () -> Void
        
        var body: some View {
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
                    ZStack {
                        Image(systemName: "play.fill")
                            .opacity(0)  // Hidden but maintains space
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    }
                }
                
                Button {
                    onForwardFrame()
                } label: {
                    Image(systemName: "forward.frame.fill")
                }
                .buttonRepeatBehavior(.enabled)
                
            }
            .foregroundStyle(.secondary)
            .controlSize(.regular)
            .buttonStyle(.borderless)
            .contextMenu {
                Button("Reset") {
                    onReset()
                }
            }
        }
    }
}
