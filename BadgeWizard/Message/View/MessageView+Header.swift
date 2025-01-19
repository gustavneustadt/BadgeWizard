//
//  Header.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//


import SwiftUI
import Combine

extension MessageView {
    struct Header: View {
        let messageNumber: Int
        let gridSum: Int
        let columnSum: Int
        let selected: Bool
        
        var body: some View {
            
            let padding: (x: CGFloat, y: CGFloat) = (x: 5, y: 3)
            return VStack {
                HStack {
                    HStack(spacing: 0) {
                        Text("Message \(messageNumber)")
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundStyle(selected ? .white : .primary)
                            .fontWeight(.medium)
                            .padding(.horizontal, padding.x)
                            .padding(.vertical, padding.y)
                            .background(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(selected ? Color.accentColor : Color.clear)
                            )
                        Spacer()
                    }
                    Text("\(gridSum) Grids")
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 0) {
                        Spacer()
                        Text("\(columnSum) Columns in Total")
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
                .offset(y: -padding.y)
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    MessageView.Header(messageNumber: 1, gridSum: 2, columnSum: 10, selected: true)
}
