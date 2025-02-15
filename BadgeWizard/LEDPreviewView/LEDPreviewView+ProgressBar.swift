//
//  LEDPreviewView+ProgressBar.swift
//  BadgeWizard
//
//  Created by Gustav on 15.02.25.
//

import SwiftUI

extension LEDPreviewView {
    struct ProgressBar: View {
        @State var progressBarSize: CGSize = .zero
        
        let progress: Int
        let total: Int
        var progressWidth: CGFloat {
            Double(progress) / Double(total) * progressBarSize.width
        }
        
        func getDuration(_ steps: Int) -> String {
            // 0.025 is the refresh rate → each 0.025 seconds
            let value = 0.025 * Double(steps)
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = value < 60 ? [.second] : [.minute, .second]
            formatter.allowsFractionalUnits = true
            formatter.unitsStyle = .short
            
            return formatter.string(from: value) ?? "\(value) seconds"
        }
        
        var totalAnimationDuration: String {
            getDuration(total)
        }
        
        var bar: some View {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.secondary.opacity(0.2))
                Rectangle()
                    .fill(.secondary.opacity(0.5))
                    .frame(width: progressWidth)
                    .animation(.linear(duration: 0.2), value: progressWidth)
            }
            .frame(height: 2)
            .getSize($progressBarSize)
        }
        
        var durationLabels: some View {
            HStack {
                Text(getDuration(progress))
                    .textCase(.uppercase)
                    .font(.footnote.monospacedDigit())
                Spacer()
                Text(getDuration(total))
                    .textCase(.uppercase)
                    .font(.footnote.monospacedDigit())
            }
        }
        
        var body: some View {
            VStack {
                bar
                durationLabels
            }
        }
    }
    
}
