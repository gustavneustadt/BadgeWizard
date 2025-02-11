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
    @Bindable var pixelGrid: PixelGrid
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
                
                if pixelGrid.message?.selectedGridId != pixelGrid.id {
                    pixelGrid.message?.selectGrid(pixelGrid.id)
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
        pixelGrid.message?.selectedGridId == pixelGrid.id
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
                    onionSkinning: pixelGrid.message?.onionSkinning ?? false,
                    pixelSize: settings.pixelGridPixelSize
                )
                .frame(width: width,
                       height: CGFloat(11 * settings.pixelGridPixelSize))
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
                #if DEBUG
                    .fill(Color.init(hue: Double.random(in: 0..<1), saturation: Double.random(in: 0..<1), brightness: 0.1))
                #endif
                    .stroke(Color.accentColor.secondary, lineWidth: gridIsSelected ? 4 : 0)
            )

            .focusEffectDisabled()
            .onTapGesture {
                if !gridIsSelected {
                    pixelGrid.message?.selectGrid(pixelGrid.id)
                }
            }
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
