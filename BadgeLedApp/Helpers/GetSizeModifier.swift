//
//  GetSizeModifier.swift
//  Reframer
//
//  Created by Gustav on 10.11.24.
//

import SwiftUI

struct GetSizeModifier: ViewModifier {
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { geometryProxy in
                Color.clear
                    .onAppear {  // Update the size initially and whenever changes occur
                        self.size = geometryProxy.size
                    }
                    .onChange(of: geometryProxy.size, initial: true, { _, newSize in
                        self.size = newSize
                    })
            })
    }
}

extension View {
    func getSize(_ size: Binding<CGSize>) -> some View {
        modifier(GetSizeModifier(size: size))
    }
}
