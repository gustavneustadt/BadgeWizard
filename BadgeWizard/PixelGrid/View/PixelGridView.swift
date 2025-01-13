//
//  MessageView+GridView.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//
import SwiftUI


struct PixelGridView: View {
    @EnvironmentObject var messageStore: MessageStore
    @ObservedObject var pixelGrid: PixelGrid
    @State private var showPopover = false
    var onTrailingWidthChanged: (Int) -> Void = { _ in }
    var onLeadingWidthChanged: (Int) -> Void = { _ in }
    var onPixelChanged: () -> Void = { }
    @FocusState private var isFocused: Bool
    
    @State private var drawMode: Bool = true
    @Environment(\.undoManager) var undo
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let pixelSize: CGFloat = 20 // 20px + 1px spacing
                
                let x = Int(value.location.x / pixelSize)
                let y = Int(value.location.y / pixelSize)
                
                if x >= 0 && x < pixelGrid.width && y >= 0 && y < pixelGrid.height {
                    if value.translation == .zero {
                        // This is the start of the drag - set mode based on initial pixel
                        drawMode = !pixelGrid.pixels[y][x].isOn
                    }
                    pixelGrid.setPixel(x: x, y: y, isOn: drawMode, undoManager: undo)
                }
            }
    }
    
    var body: some View {
        PixelGridImage(pixelGrid: pixelGrid)
            .frame(width: CGFloat(pixelGrid.width * 20),
                   height: CGFloat(11 * 20))
            .gesture(
                dragGesture
            )
            .padding([.top, .bottom, .leading])
            .padding(.trailing, 19)
            .overlay {
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                showPopover.toggle()
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
                    .foregroundStyle(.background)
            )
            .contentShape(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .focusable()
            .focused($isFocused)
            .onChange(of: isFocused, initial: true, { oldValue, newValue in
                messageStore.selectedGridId = newValue ? pixelGrid.id : nil
                messageStore.selectedMessageId = newValue ? pixelGrid.message.id : messageStore.selectedMessageId
            })
            .popover(isPresented: $showPopover, attachmentAnchor: .point(UnitPoint.bottomLeading), arrowEdge: .bottom, content: {
                GridControlsPopover(pixelGrid: pixelGrid)
            })
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




// #Preview {
//     @Previewable @State var pixelGrid: PixelGrid = .init(parent: .init())
//     GridView(
//         pixelGrid: pixelGrid
//     )
//         .padding()
// }
