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
        // Verify the font exists before proceeding
        guard NSFont(name: fontName, size: 12) != nil else { return [] }
        let fontManager = NSFontManager.shared
        
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
            // Convert weight to the equivalent NSFontManager weight
            let managerWeight = convertToManagerWeight(weight)
            // Try to create a font with this weight
            let weightedFont = fontManager.font(withFamily: fontName, traits: [], weight: Int(managerWeight), size: 12)
            return weightedFont != nil
        }
    }
    
    // Convert NSFont.Weight to NSFontManager weight values
    private func convertToManagerWeight(_ weight: NSFont.Weight) -> Int {
        switch weight {
        case .ultraLight: return 2    // NSFontWeightUltraLight
        case .thin: return 3          // NSFontWeightThin
        case .light: return 4         // NSFontWeightLight
        case .regular: return 5       // NSFontWeightRegular
        case .medium: return 6        // NSFontWeightMedium
        case .semibold: return 7      // NSFontWeightSemibold
        case .bold: return 8          // NSFontWeightBold
        case .heavy: return 9         // NSFontWeightHeavy
        case .black: return 10        // NSFontWeightBlack
        default: return 5             // Default to regular
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
            let availableWeights = getAvailableWeights(for: selectedFontName)
            if !availableWeights.isEmpty {
                Picker("Weight", selection: $selectedWeight) {
                    ForEach(availableWeights, id: \.self) { weight in
                        Text(weightName(for: weight))
                            .tag(weight)
                    }
                }
                .onChange(of: selectedFontName) {
                    // If the current weight isn't available in the new font, select the first available weight
                    if !availableWeights.contains(selectedWeight) {
                        selectedWeight = availableWeights[0]
                    }
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
