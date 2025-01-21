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
    var onIsDrawingChanged: (Bool) -> Void = { _ in }
    @FocusState private var isFocused: Bool
    @State var isDrawing: Bool = false
    @State var isDragging: Bool = false
    @State var temporaryWidth: Int? = nil
    @State var hoveringDragHandle: Bool = false
    
    @State var mousePosition: CGPoint? = nil
    
    @State private var drawMode: Bool = true
    @Environment(\.undoManager) var undo
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onEnded { _ in
                isDrawing = false
            }
            .onChanged { value in
                mousePosition = value.location
                isDrawing = true
                
                if messageStore.selectedGridId != pixelGrid.id {
                    messageStore.selectedGridId = pixelGrid.id
                    messageStore.selectedMessageId = pixelGrid.message.id
                }
                
                let pixelSize: CGFloat = 20 // 20px + 1px spacing
                
                let x = Int((value.location.x - 2) / pixelSize)
                let y = Int((value.location.y - 2) / pixelSize)
                
                if x >= 0 && x < pixelGrid.width && y >= 0 && y < pixelGrid.height {
                    if value.translation == .zero {
                        // This is the start of the drag - set mode based on initial pixel
                        drawMode = !pixelGrid.pixels[y][x].isOn
                    }
                    pixelGrid.setPixel(x: x, y: y, isOn: drawMode, undoManager: undo)
                }
            }
    }
    
    var gridIsSelected: Bool {
        messageStore.selectedGridId == pixelGrid.id
    }
    
    func calculateWidth(columns: Int) -> CGFloat {
        CGFloat(columns * 20)
    }
    
    var width: CGFloat {
        calculateWidth(columns: pixelGrid.width)
    }
    
    var body: some View {
        let spring = Animation.interpolatingSpring(mass: 0.04, stiffness: 11.55, damping: 1.17, initialVelocity: 8.0)
        VStack {
            HStack {
                Button {
                    _ = withAnimation(spring) {
                        pixelGrid.message.reorderGrid(id: pixelGrid.id, direction: .backward)
                    }
                } label: {
                    Image(systemName: "arrow.left")
                }
                .disabled(pixelGrid.message.isGridAt(id: pixelGrid.id, position: .start))
                Button {
                    _ = withAnimation(spring) {
                        pixelGrid.message.reorderGrid(id: pixelGrid.id, direction: .forward)
                    }
                } label: {
                    Image(systemName: "arrow.right")
                }
                .disabled(pixelGrid.message.isGridAt(id: pixelGrid.id, position: .end))
                Spacer()
            }
            .controlSize(.small)
            .opacity(gridIsSelected ? 1 : 0)
            
            HStack(spacing: 0) {
                PixelGridImage(
                    pixelGrid: pixelGrid,
                    mousePosition: mousePosition,
                    onionSkinning: pixelGrid.message.onionSkinning
                )
                .frame(width: width,
                       height: CGFloat(11 * 20))
                .onContinuousHover(coordinateSpace: .local, perform: { phase in
                    switch phase {
                    case .active(let pt):
                        mousePosition = pt
                    case .ended:
                        mousePosition = nil
                    }
                })
                .gesture(
                    dragGesture
                )
                .padding([.top, .bottom, .leading])
                .padding(.trailing, 19)
                .overlay {
                    ZStack {
                        HStack {
                            Spacer()
                            dragHandleTrailing
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.trailing, 8)
                if temporaryWidth != nil {
                    let width = calculateWidth(columns: temporaryWidth!) - self.width
                    if width > 0 {
                        Color.clear
                            .frame(
                                width: width
                            )
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.background)
                    .stroke(Color.accentColor.secondary, lineWidth: gridIsSelected ? 4 : 0)
            )
            .focusable()
            .focused($isFocused)
            .focusEffectDisabled()
            .onTapGesture {
                isFocused = true
            }
            .onChange(of: isFocused, initial: true, { oldValue, newValue in
                if !gridIsSelected && newValue == true {
                    messageStore.selectedGridId = pixelGrid.id
                }
                messageStore.selectedMessageId = newValue ? pixelGrid.message.id : messageStore.selectedMessageId
                
            })
        }
    }
    
    var dragHandleTrailing: some View {
        DragHandle(
            hoveringDragHandle: hoveringDragHandle || temporaryWidth != nil
        )
        .onHover { hovering in
            hoveringDragHandle = hovering
        }
        .pointerStyle(.frameResize(position: .trailing))
        .gesture(
            DragGesture()
                .onEnded({ _ in
                    withAnimation(.easeInOut) {
                        temporaryWidth = 0
                    }
                    temporaryWidth = nil
                })
                .onChanged { value in
                    let newWidth = max(1, pixelGrid.width + Int(value.translation.width / 20))
                    if temporaryWidth == nil {
                        temporaryWidth = newWidth
                    }
                    onTrailingWidthChanged(newWidth)
                }
        )
    }
}
