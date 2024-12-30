//
//  MessageChunk.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//


class MessageChunk: Identifiable {
    var id: Identifier<MessageChunk> = .init()
    var bitmap: [String]
    
    init(bitmap: [String]) {
        self.bitmap = bitmap
    }
}