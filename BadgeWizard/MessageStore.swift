//
//  MessageStore.swift
//  BadgeLedApp
//
//  Created by Gustav on 12.01.25.
//

import SwiftUI

class MessageStore: ObservableObject {
    @Published var messages: [Message]
    @Published var selectedMessageId: Identifier<Message>?
    @Published var selectedGridId: Identifier<PixelGrid>?
    
    
    init(messages: [Message], selectedMessageId: Identifier<Message>? = nil, selectedGridId: Identifier<PixelGrid>? = nil) {
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
        guard messages.count < 8 else { return }
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
    
    func deleteGrid(_ id: Identifier<PixelGrid>) {
        messages.forEach { message in
            if let index = message.pixelGrids.firstIndex(where: { grid in
                return grid.id == id
            }) {
                message.pixelGrids.remove(at: index)
                if message.pixelGrids.isEmpty {
                    message.addGrid()
                }
                return
            }
            
        }
    }
}
