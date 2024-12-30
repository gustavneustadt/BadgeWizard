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
        var names = NSFontManager.shared.availableFontFamilies.sorted()
        
        names.append("Apple MacOS 8.0")
        
        return names
        
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
