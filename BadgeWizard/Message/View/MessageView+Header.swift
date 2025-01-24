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
        @ObservedObject var message: Message
        let messageNumber: Int
        let gridSum: Int
        let columnSum: Int
        let selected: Bool
        
        var body: some View {
            
            let padding: (x: CGFloat, y: CGFloat) = (x: 5, y: 3)
            return VStack {
                HStack {
                    HStack {
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
                    HStack {
                        Text("\(gridSum) Grids")
                        Text("·")
                        Text("\(columnSum) Columns")
                    }
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    
                    HStack(spacing: 0) {
                        Spacer()
                        Toggle(isOn: $message.onionSkinning) {
                            Text("Onion Skinning")
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                }
                .offset(y: -padding.y)
                Spacer()
            }
            .padding()
        }
    }
}

// #Preview {
//     MessageView.Header(messageNumber: 1, gridSum: 2, columnSum: 10, selected: true)
// }
