//
//  PixelView.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import SwiftUI

struct PixelView: View {
    let isOn: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(isOn ? Color.blue : Color.gray.opacity(0.3))
            .border(Color.black.opacity(0.2), width: 1)
    }
}
