//
//  FontPicker.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import SwiftUI

struct FontNameSelector: View {
    @Binding var selectedFontName: String
    
    var fontNames: [String] {
        let names = NSFontManager.shared.availableFontFamilies
        return names.sorted()
    }
    
    var body: some View {
        Picker("Font", selection: $selectedFontName) {
            ForEach(fontNames, id: \.self) { fontName in
                Text(fontName)
                    .tag(fontName)
            }
        }
    }
}
