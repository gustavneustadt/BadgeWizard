//
//  GridView.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//
import SwiftUI

struct GridView: View {
    var pixelGrid: PixelGrid
    
    var onWidthChange: (Int) -> Void = { _ in }
    
    var body: some View {
        PixelEditorView(model: pixelGrid)
        .padding()
        .padding(.trailing, 8)
        .overlay {
            HStack {
                Spacer()
                VStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                    }
                    .buttonStyle(.borderless)
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .frame(width: 4, height:80)
                        .foregroundStyle(.secondary.opacity(0.5))
                        .pointerStyle(.frameResize(position: .trailing))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    onWidthChange(
                                        max(1, pixelGrid.width + Int(value.translation.width / 20))
                                    )
                                }
                        )
                }
                // .border(.pink)
                .padding(5)
            }
        }
    }
}
// 
// #Preview {
//     @Previewable @State var pixelGrid: PixelGrid = .init()
//     GridView(
//         pixelGrid: pixelGrid
//     )
//         .padding()
// }
