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
        
        var body: some View {
            HStack {
                VStack {
                    Text("Message \(messageNumber)")
                        .foregroundStyle(.secondary)
                        .fontWeight(.medium)
                    Spacer()
                }
                Spacer()
                VStack {
                    Text("\(columnSum) Columns in Total")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            .padding()
        }
    }
}
