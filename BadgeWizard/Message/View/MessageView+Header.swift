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
        let columnSum: Int
        let selected: Bool
        
        var body: some View {
            
            let padding: (x: CGFloat, y: CGFloat) = (x: 5, y: 3)
            return HStack {
                VStack {
                    Text("Message \(messageNumber)")
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundStyle(.primary)
                        .fontWeight(.medium)
                        .padding(.horizontal, padding.x)
                        .padding(.vertical, padding.y)
                        .background(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(selected ? Color.accentColor : Color.clear)
                        )
                        .offset(x: -padding.x, y: -padding.y)
                    Spacer()
                }
                Spacer()
                VStack {
                    Text("\(columnSum) Columns in Total")
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            .padding()
        }
    }
}

#Preview {
    MessageView.Header(messageNumber: 1, columnSum: 10, selected: true)
}
