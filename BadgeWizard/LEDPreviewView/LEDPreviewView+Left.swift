//
//  LEDPreviewView+Left.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//

extension LEDPreviewView {
    internal func scrollLeft(_ buffer: inout [[Bool]]) {
        // reset position when all the pixels scrolled through
        if Int(currentPosition) > pixels[0].count + 44 {
            currentPosition = 0
        }
        
        let offset = Int(currentPosition)
        
        for y in 0..<11 {
            for x in 0..<44 {
                let sourceX = x + offset - 44
                if sourceX >= 0 && sourceX < pixels[0].count {
                    buffer[y][x] = pixels[y][sourceX].isOn
                } else {
                    buffer[y][x] = false
                }
            }
        }
    }
}