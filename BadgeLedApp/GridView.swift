//
//  GridView.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//
import SwiftUI

struct GridView: View {
    @ObservedObject var pixelGrid: PixelGrid
    
    var onTrailingWidthChanged: (Int) -> Void = { _ in }
    var onLeadingWidthChanged: (Int) -> Void = { _ in }
    var onPixelChanged: () -> Void = { }
    
    
    var body: some View {
        PixelEditorView(model: pixelGrid)
            .padding([.top, .bottom, .leading])
            .padding(.trailing, 19)
        .overlay {
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                
                            } label: {
                                Image(systemName: "ellipsis.circle.fill")
                            }
                            .buttonStyle(.borderless)
                            .frame(width: 20, height: 20)
                        }
                        Spacer()
                    }
                    .padding(.top)
                    HStack {
                        Spacer()
                        dragHandleTrailing
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: pixelGrid.pixels) {
                    onPixelChanged()
                }
        }
        .padding(.trailing, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.background)
        )
    }

    var dragHandleTrailing: some View {
        ZStack {
            UnevenRoundedRectangle(
                cornerRadii:
                        .init(
                            topLeading: 3,
                            bottomLeading: 3,
                            bottomTrailing: 10,
                            topTrailing: 10
                        ),
                style: .continuous)
            .frame(width: 18, height:59)
            .foregroundStyle(.tertiary)
            HStack(spacing: 2) {
                Rectangle()
                    .frame(width: 1)
                Rectangle()
                    .frame(width: 1)
                Rectangle()
                    .frame(width: 1)
            }
            .foregroundStyle(.black.opacity(0.4))
            .frame(height: 30)
        }
        .pointerStyle(.frameResize(position: .trailing))
        .gesture(
            DragGesture()
                .onChanged { value in
                    onTrailingWidthChanged(
                        max(1, pixelGrid.width + Int(value.translation.width / 20))
                    )
                }
        )
    }
}
#Preview {
    @Previewable @State var pixelGrid: PixelGrid = .init(parent: .init())
    GridView(
        pixelGrid: pixelGrid
    )
        .padding()
}
