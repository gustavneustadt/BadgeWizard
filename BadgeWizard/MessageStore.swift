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
}
