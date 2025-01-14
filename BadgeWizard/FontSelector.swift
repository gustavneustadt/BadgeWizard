//
//  FontNameSelector.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import SwiftUI

struct FontSelector: View {
    @Binding var selectedFontName: String
    @Binding var selectedStyle: String
    
    var fontNames: [String] {
        let names = NSFontManager.shared.availableFontFamilies
        return names.sorted()
    }
    
    func getAvailableStyle(for fontName: String) -> [(display: String, postscript: String)] {
        let fontManager = NSFontManager.shared
        
        guard fontManager.availableFontFamilies.contains(fontName) else {
            print("Error: Font '\(fontName)' not found")
            return []
        }
        
        guard let members = fontManager.availableMembers(ofFontFamily: fontName) else {
            print("Error: Could not get font members")
            return []
        }
        
        var result: [(display: String, postscript: String)] = []
        for member in members {
            if let postScriptName = member[0] as? String,
               let displayName = member[1] as? String {
                result.append((display: displayName, postscript: postScriptName))
            }
        }
        
        return result
    }
            
    var body: some View {
        Picker("Font", selection: $selectedFontName) {
            ForEach(fontNames, id: \.self) { fontName in
                Text(fontName)
                    .tag(fontName)
            }
        }
        
        let availableStyle = getAvailableStyle(for: selectedFontName)
            Picker("Style", selection: $selectedStyle) {
                ForEach(availableStyle, id: \.self.postscript) { style in
                    Text(style.display)
                        .tag(style.postscript)
                }
            }
            .onChange(of: selectedFontName, initial: true) {
                // listFontInfo(fontName: selectedFontName)
                // If the current weight isn't available in the new font, select the first available weight
                // if !availableWeights.contains(selectedWeight) {
                //     selectedWeight = availableWeights[0]
                // }
                selectedStyle = getAvailableStyle(for: selectedFontName).first?.postscript ?? ""
            }
        
    }
    
    func weightName(for weight: NSFont.Weight) -> String {
        switch weight {
        case .ultraLight: return "Ultra Light"
        case .thin: return "Thin"
        case .light: return "Light"
        case .regular: return "Regular"
        case .medium: return "Medium"
        case .semibold: return "Semibold"
        case .bold: return "Bold"
        case .heavy: return "Heavy"
        case .black: return "Black"
        default: return "Regular"
        }
    }
}
