//
//  FontNameSelector.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import SwiftUI

struct FontSelector: View {
    @Binding var selectedFontName: String
    @Binding var selectedWeight: NSFont.Weight
    
    var fontNames: [String] {
        let names = NSFontManager.shared.availableFontFamilies
        return names.sorted()
    }
    
    func getAvailableWeights(for fontName: String) -> [NSFont.Weight] {
        let fontManager = NSFontManager.shared
        guard let font = NSFont(name: fontName, size: 12) else { return [] }
        
        let weights: [NSFont.Weight] = [
            .ultraLight,
            .thin,
            .light,
            .regular,
            .medium,
            .semibold,
            .bold,
            .heavy,
            .black
        ]
        
        return weights.filter { weight in
            let descriptor = font.fontDescriptor.addingAttributes([
                .traits: [
                    NSFontDescriptor.TraitKey.weight: weight
                ]
            ])
            return NSFont(descriptor: descriptor, size: 12) != nil
        }
    }
    
    var body: some View {
            Picker("Font", selection: $selectedFontName) {
                ForEach(fontNames, id: \.self) { fontName in
                    Text(fontName)
                        .tag(fontName)
                }
            }
            
            if !selectedFontName.isEmpty {
                Picker("Weight", selection: $selectedWeight) {
                    ForEach(getAvailableWeights(for: selectedFontName), id: \.self) { weight in
                        Text(weightName(for: weight))
                            .tag(weight)
                    }
                }
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
