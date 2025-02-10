//
//  MessageStore.swift
//  BadgeLedApp
//
//  Created by Gustav on 12.01.25.
//

import SwiftUI

class MessageStore: ObservableObject {
    @Published var messages: [Message]
    
    
    init(messages: [Message], selectedMessageId: UUID? = nil, selectedGridId: UUID? = nil) {
        self.messages = messages
        self.messages.forEach({ message in
            message.store = self
        })
    }

    @discardableResult
    func addMessage() -> Message? {
        guard messages.count < 8 else { return nil }
        let newMessage = Message(store: self)
        messages.append(newMessage)
        return newMessage
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
    
    func deleteGrid(_ id: UUID) {
        messages.forEach { message in
            if let index = message.pixelGrids.firstIndex(where: { grid in
                return grid.id == id
            }) {
                message.pixelGrids.remove(at: index)
                
                if message.pixelGrids.isEmpty {
                    message.newGrid()
                }
                
                return
            }
            
        }
    }
}
