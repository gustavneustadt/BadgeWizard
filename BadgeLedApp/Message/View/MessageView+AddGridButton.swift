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
        let action: () -> Void
        var body: some View {
            VStack {
                Button {
                    action()
                } label: {
                    Label {
                        Text("Add Grid")
                    } icon: {
                        Image("square.plus")
                    }
                }
                .controlSize(.extraLarge)
            }
        }
    }
}
