//
//  MessageView+GridView.swift
//  BadgeLedApp
//
//  Created by Gustav on 30.12.24.
//
import SwiftUI

struct PixelGridView: View {
    @EnvironmentObject var messageStore: MessageStore
    @EnvironmentObject private var settings: SettingsStore
    var pixelGrid: PixelGrid
    @State var cachedPixelGrid: PixelGrid?
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
                    messageStore.selectedMessageId =  pixelGrid.message != nil ? pixelGrid.message!.id : nil
                }
                
                let pixelSize = settings.pixelGridPixelSize
                
                let x = Int((value.location.x - 2) / pixelSize)
                let y = Int((value.location.y - 2) / pixelSize)
                
                if x >= 0 && x < pixelGrid.width && y >= 0 && y < pixelGrid.height {
                    if value.translation == .zero {
                        // This is the start of the drag - set mode based on initial pixel
                        drawMode = !pixelGrid.pixels[y][x]
                    }
                    pixelGrid.setPixel(x: x, y: y, isOn: drawMode, undoManager: undo)
                }
            }
    }
    
    var gridIsSelected: Bool {
        messageStore.selectedGridId == pixelGrid.id
    }
    
    func calculateWidth(columns: Int) -> CGFloat {
        CGFloat(columns) * settings.pixelGridPixelSize
    }
    
    var width: CGFloat {
        calculateWidth(columns: pixelGrid.width)
    }
    
    var body: some View {
        let spring = Animation.interpolatingSpring(mass: 0.04, stiffness: 11.55, damping: 1.17, initialVelocity: 8.0)
        VStack {
            HStack {
                Button {
                    withAnimation(spring) {
                        pixelGrid.reorder(direction: .backward)
                    }
                } label: {
                    Image(systemName: "arrow.left")
                }
                .disabled(pixelGrid.isAt(position: .start))
                Button {
                    withAnimation(spring) {
                        pixelGrid.reorder(direction: .forward)
                    }
                } label: {
                    Image(systemName: "arrow.right")
                }
                .disabled(pixelGrid.isAt(position: .end))
                Spacer()
            }
            .controlSize(.small)
            .opacity(gridIsSelected ? 1 : 0)
            
            HStack(spacing: 0) {
                PixelGridImage(
                    pixelGrid: pixelGrid,
                    mousePosition: mousePosition,
                    onionSkinning: pixelGrid.message?.onionSkinning ?? false,
                    pixelSize: settings.pixelGridPixelSize
                )
                .frame(width: width,
                       height: CGFloat(11 * settings.pixelGridPixelSize))
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
                .padding([.top, .bottom, .leading], settings.pixelGridPixelSize)
                .padding(.trailing, settings.pixelGridPixelSize)
                .overlay {
                    ZStack {
                        HStack {
                            Spacer()
                            dragHandleTrailing
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.trailing, settings.pixelGridPixelSize * 0.4)
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
                RoundedRectangle(cornerRadius: settings.pixelGridPixelSize / 2, style: .continuous)
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
                guard let message = pixelGrid.message else { return }
                messageStore.selectedMessageId = newValue ? message.id : messageStore.selectedMessageId
                
            })
        }
    }
    
    var dragHandleTrailing: some View {
        DragHandle(
            hoveringDragHandle: hoveringDragHandle || temporaryWidth != nil,
            pixelSize: settings.pixelGridPixelSize
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
                    cachedPixelGrid = nil
                    temporaryWidth = nil
                })
                .onChanged { value in
                    let newWidth = max(1, pixelGrid.width + Int(value.translation.width / settings.pixelGridPixelSize))
                    if temporaryWidth == nil {
                        temporaryWidth = newWidth
                        cachedPixelGrid = pixelGrid
                    }
                    pixelGrid.resizeFromTrailingEdge(to: newWidth, cache: cachedPixelGrid, undoManager: undo)
                }
        )
    }
}
