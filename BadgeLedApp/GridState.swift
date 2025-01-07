//
//  GridState.swift
//  BadgeLedApp
//
//  Created by Gustav on 07.01.25.
//
import SwiftUI

class GridState: ObservableObject {
    
    @Published var pixelGrids: [PixelGrid] = []
    init() {
        self.addGrid()
    }
    
    func addGrid() {
        let lastPixelGrid = pixelGrids.last?.duplicate()
        
        pixelGrids.append(lastPixelGrid ?? .init(parent: self, width: lastPixelGrid?.width))
    }
}

