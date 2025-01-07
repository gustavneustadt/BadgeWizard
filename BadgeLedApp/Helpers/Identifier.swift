//
//  Identifier.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//

import SwiftUI

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
