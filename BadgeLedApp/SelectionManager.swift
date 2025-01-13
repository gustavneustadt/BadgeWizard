//
//  FocusState.swift
//  BadgeLedApp
//
//  Created by Gustav on 12.01.25.
//

import SwiftUI

class SelectionManager: ObservableObject {
    @Published var selectedMessageId: Message.ID?
    @Published var selectedGridId: PixelGrid.ID?
}
