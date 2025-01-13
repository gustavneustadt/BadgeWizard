//
//  Pixel.swift
//  BadgeLedApp
//
//  Created by Gustav on 31.12.24.
//
import SwiftUI

struct Pixel: Hashable, Identifiable, Equatable {
    let id: Identifier<Pixel> = .init()
    let x: Int
    let y: Int
    let isOn: Bool
}
