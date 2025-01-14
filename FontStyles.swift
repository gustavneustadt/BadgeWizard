//
//  FontStyles.swift
//  BadgeWizard
//
//  Created by Gustav on 14.01.25.
//

import Foundation
import AppKit

struct FontStyle {
    let postScriptName: String
    let displayName: String
    let weight: NSFont.Weight
    let isItalic: Bool
}

func getFontStyles(fontName: String) -> [FontStyle] {
    let fontManager = NSFontManager.shared
    
    guard let members = fontManager.availableMembers(ofFontFamily: fontName) else {
        return []
    }
    
    return members.compactMap { member in
        guard let postScriptName = member[0] as? String,
              let displayName = member[1] as? String,
              let weightNumber = member[2] as? Int,
              let traits = member[3] as? UInt else {
            return nil
        }
        
        let fontWeight: NSFont.Weight = {
            switch weightNumber {
            case 1...2: return .ultraLight
            case 3: return .thin
            case 4: return .light
            case 5: return .regular
            case 6: return .medium
            case 7...8: return .semibold
            case 9: return .bold
            case 10...11: return .heavy
            case 12...15: return .black
            default: return .regular
            }
        }()
        
        let isItalic = (traits & NSFontTraitMask.italicFontMask.rawValue) != 0
        
        return FontStyle(
            postScriptName: postScriptName,
            displayName: displayName,
            weight: fontWeight,
            isItalic: isItalic
        )
    }
}
