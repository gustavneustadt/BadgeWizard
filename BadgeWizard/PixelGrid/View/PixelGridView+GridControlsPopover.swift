//
//  GridControl.swift
//  BadgeLedApp
//
//  Created by Gustav on 09.01.25.
//

import Foundation
import SwiftUI

extension PixelGridView {
    struct GridControlsPopover: View {
        let pixelGrid: PixelGrid
        @State var fontName: String = ""
        @State var kerning: Double = 0
        @State var fontSize: Double = 12
        @State var text: String = ""
        @State var fontWeight: NSFont.Weight = .regular

        let onApplyText: ([[Pixel]]) -> Void = { _ in }
        let onClearGrid: () -> Void = {}
        let onFillGrid: () -> Void = {}
        let onInvertGrid: () -> Void = {}
        
        func updateText() {
            pixelGrid.applyText(text, postscriptFontName: fontName, size: fontSize, kerning: kerning)
        }
        
        var body: some View {
            Form {
                // FontSelector(
                //     selectedFontName: $fontName,
                //     selectedWeight: $fontWeight
                // )
                TextField("Kerning:", value: $kerning, format: .number)
                TextField("Font Size:", value: $fontSize, format: .number)
                TextField(text: $text) {
                    Text("Set text to:")
                }
                
                GroupBox("Grid Actions") {
                    VStack(spacing: 8) {
                        Button("Clear Grid", action: onClearGrid)
                            .frame(maxWidth: .infinity)
                        
                        Button("Fill Grid", action: onFillGrid)
                            .frame(maxWidth: .infinity)
                        
                        Button("Invert Grid", action: onInvertGrid)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding()
            .frame(width: 280)
            .onChange(of: text) {
                updateText()
            }
            .onChange(of: kerning) {
                guard !text.isEmpty else { return }
                updateText()
            }
            .onChange(of: fontSize) {
                guard !text.isEmpty else { return }
                updateText()
            }
            .onChange(of: fontWeight) {
                guard !text.isEmpty else { return }
                updateText()
            }
            
        }
    }
}

