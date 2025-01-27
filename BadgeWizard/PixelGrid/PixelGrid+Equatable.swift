//
//  Pixel+Equatable.swift
//  BadgeLedApp
//
//  Created by Gustav on 31.12.24.
//

import Foundation
extension PixelGrid: Equatable {
    static func == (lhs: PixelGrid, rhs: PixelGrid) -> Bool {
        // Compare the relevant properties
        return lhs.pixels == rhs.pixels &&
        lhs.width == rhs.width &&
        lhs.height == rhs.height
    }    
}
