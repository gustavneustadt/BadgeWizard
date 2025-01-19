//
//  MessageStore.swift
//  BadgeLedApp
//
//  Created by Gustav on 12.01.25.
//

import SwiftUI

class MessageStore: ObservableObject {
    @Published var messages: [Message]
    @Published var selectedMessageId: Message.ID?
    @Published var selectedGridId: PixelGrid.ID?
    
    
    init(messages: [Message], selectedMessageId: Message.ID? = nil, selectedGridId: PixelGrid.ID? = nil) {
        self.messages = messages
        self.messages.forEach({ message in
            message.store = self
        })
        
        // Pre select a Message and a Grid
        self.selectedMessageId = selectedMessageId ?? messages.first?.id
        self.selectedGridId = selectedGridId ?? messages.first?.pixelGrids.first?.id
    }
    
    // Computed property for easy access to selected message
    var selectedMessage: Message? {
        guard let id = selectedMessageId else { return nil }
        return messages.first { $0.id == id }
    }
    
    var selectedGrid: PixelGrid? {
        guard let id = selectedGridId else { return nil }
        return selectedMessage?.pixelGrids.first { $0.id == id }
    }
    
    func addMessage() {
        let newMessage = Message(store: self)
        messages.append(newMessage)
        self.selectedMessageId = newMessage.id
    }
    
    func updateMessageCount(to count: Int, undoManager: UndoManager?) {
        let current = messages.count
        if count > current {
            for _ in current..<count {
                addMessage()
            }
        } else if count < current {
            for _ in count..<current {
                messages.removeLast()
            }
        }
    }
}
