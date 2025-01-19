//
//  AddGridButton.swift
//  BadgeLedApp
//
//  Created by Gustav on 08.01.25.
//

import SwiftUI
import Combine

extension MessageView {
    struct AddGridButton: View {
        let action: (_ duplicate: Bool) -> Void
        @State var modifierOption: Bool = false
        var body: some View {
                Button {
                    action(modifierOption)
                } label: {
                    Label {
                        Text(modifierOption ? "Duplicate Grid" : "Add Grid")
                    } icon: {
                        Image("square.plus")
                    }
                }
                .controlSize(.extraLarge)
                .onModifierKeysChanged { old, new in
                    guard new.contains(.option) else {
                        modifierOption = false
                        return
                    }
                    modifierOption = true
                }
        }
    }
}
