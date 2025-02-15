import SwiftUI

struct FontSelector: View {
    @Binding var selectedFont: String
    
    @State var selectedFontName: String = ""
    @State var selectedStyle: String = ""
    @State private var styleState: StyleState = .empty
    
    var fontNames: [String] {
        let names = NSFontManager.shared.availableFontFamilies
        return names.sorted()
    }
    
    private struct FontStyle: Equatable {
        let display: String
        let postscript: String
    }
    
    private struct StyleState: Equatable {
        var styles: [FontStyle]
        var selectedPostscript: String
        
        static let empty = StyleState(styles: [], selectedPostscript: "")
    }
    
    init(selectedFont: Binding<String>) {
        self._selectedFont = selectedFont
        if let firstFont = NSFontManager.shared.availableFontFamilies.first {
            self._selectedFontName = State(initialValue: firstFont)
        }
    }
    
    private func getAvailableStyles(for fontName: String) -> [FontStyle] {
        let fontManager = NSFontManager.shared
        
        guard !fontName.isEmpty,
              fontManager.availableFontFamilies.contains(fontName) else {
            return []
        }
        
        guard let members = fontManager.availableMembers(ofFontFamily: fontName) else {
            return []
        }
        
        return members.compactMap { member in
            guard let postScriptName = member[0] as? String,
                  let displayName = member[1] as? String else {
                return nil
            }
            return FontStyle(display: displayName, postscript: postScriptName)
        }
    }
    
    func updateStyleState(for fontName: String) {
        let styles = getAvailableStyles(for: fontName)
        
        // Check if the current selected style exists in the new font's styles
        // We compare the display names because that's what we want to preserve
        let currentStyleDisplayName = styleState.styles
            .first { $0.postscript == styleState.selectedPostscript }?
            .display
        
        let matchingStyle = styles.first { $0.display == currentStyleDisplayName }
        
        let newSelectedStyle = matchingStyle?.postscript ?? styles.first?.postscript ?? ""
        
        styleState = StyleState(
            styles: styles,
            selectedPostscript: newSelectedStyle
        )
        
        selectedStyle = newSelectedStyle
    }
    
    var body: some View {
        Picker("Font:", selection: $selectedFontName) {
            ForEach(fontNames, id: \.self) { fontName in
                Text(fontName).tag(fontName)
            }
        }
        .onChange(of: selectedFontName, initial: true) { _, newValue in
            if selectedFontName.isEmpty && !fontNames.isEmpty {
                selectedFontName = fontNames[0]
            }
            updateStyleState(for: selectedFontName)
            // Update the binding with the new postscript name
            selectedFont = styleState.selectedPostscript
        }
        
        Picker("Style:", selection: $styleState.selectedPostscript) {
            ForEach(styleState.styles, id: \.postscript) { style in
                Text(style.display).tag(style.postscript)
            }
        }
        .disabled(styleState.styles.isEmpty)
        .onChange(of: styleState.selectedPostscript) { _, newValue in
            // Update the binding when style changes
            selectedFont = newValue
        }
    }
}
