//
//  Message.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import Foundation

// Swift equivalent of the Flutter code
class Message: Identifiable, Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
    
    
    var id: Identifier<Message> = .init()
    // var pixelGridModel:
    var bitmap: [String]
    var flash: Bool
    var marquee: Bool
    var speed: Speed
    var mode: Mode
    
    init(bitmap: [String], flash: Bool, marquee: Bool, speed: Speed, mode: Mode) {
        self.bitmap = bitmap
        self.flash = flash
        self.marquee = marquee
        self.speed = speed
        self.mode = mode
    }
}
