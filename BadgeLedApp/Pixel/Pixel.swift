//
//  Pixel.swift
//  BadgeLedApp
//
//  Created by Gustav on 31.12.24.
//


struct Pixel: Identifiable, Hashable, Equatable {
    let id: Identifier<Pixel> = .init()
    var x: Int
    var y: Int
    var isOn: Bool
    
    mutating func set(_ state: Bool) {
        self.isOn = state
    }
}
