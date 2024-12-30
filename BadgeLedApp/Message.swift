//
//  Message.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import Foundation

// Swift equivalent of the Flutter code
class Message: Identifiable {
    var id: Identifier<Message> = .init()
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


struct Identifier<Value>: Hashable, Codable {
    
    let value: UUID
    
    init() {
        self.value = UUID()
    }
    
    init(_ uuid: UUID) {
        self.value = uuid
    }
    
    static func fromString(_ string: String) -> Identifier<Value>? {
        guard let uuid = UUID(uuidString: string) else {
            return nil
        }
        return self.init(uuid)
    }
}

