//
//  AnimatedSideMenu.swift
//  My Orders
//
//  Created by שיראל זכריה on 27/03/2024.
//

import SwiftUI

struct AnimatedSideMenu<Content: View, MenuView: View, Background: View> : View {
    var rotatesWhenExpands: Bool = true
    var disabledInteraction: Bool = true
    var sideMenuWidth: CGFloat = 200
    var cornerRadius: CGFloat = 25
    
    @Binding var showMenu: Bool
    
    @ViewBuilder var content: (UIEdgeInsets) -> Content
    @ViewBuilder var menuView: (UIEdgeInsets) -> MenuView
    @ViewBuilder var background: Background

    @GestureState private var isDragging: Bool = false
    @State var offsetx: CGFloat = 0
    @State var lastOffsetx: CGFloat = 0
    @State var progress: CGFloat = 0

    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets ?? .zero
            
            HStack(spacing: 0) {
                GeometryReader { _ in
                    menuView(safeArea)
                }
                .frame(width: sideMenuWidth)
                .contentShape(.rect)
                
                GeometryReader { _ in
                    content(safeArea)
                }
                .frame(width: size.width)
                .overlay(content: {
                    if disabledInteraction && progress > 0 {
                        Rectangle()
                            .fill(.black.opacity(progress * 0.2))
                            .onTapGesture {
                                withAnimation(.snappy(duration: 0.3, extraBounce: 0)){
                                    reset()
                                }
                            }
                    }
                })
                .mask {
                    RoundedRectangle(cornerRadius: progress * cornerRadius)
                }
                .scaleEffect(rotatesWhenExpands ? ( 1 - progress * 0.1) : 1 , anchor: .trailing)
                .rotation3DEffect(
                    .init(degrees: rotatesWhenExpands ? (progress * -15) : 0),
                    axis: (0.0, 1.0, 0.0))
            }
            .frame(width: size.width + sideMenuWidth, height: size.height)
            .offset(x: -sideMenuWidth)
            .offset(x: offsetx)
            .contentShape(.rect)
            .simultaneousGesture(dragGesture)

        }
        .background(background)
        .ignoresSafeArea()
//        .onChange(of: showMenu, initial: true) { oldValue, newValue in
//            withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
//                if newValue {
//                    showSideBar()
//                } else {
//                    reset()
//                }
//            }
//        }
        .onChange(of: showMenu) { newValue in
            withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                if newValue {
                    showSideBar()
                } else {
                    reset()
                }
            }
        }
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .updating($isDragging) { _, out, _ in
                out = true
            }
            .onChanged { value in
                guard value.startLocation.x > 10 else { return }
                
                let translationX = isDragging ? max(min(value.translation.width + lastOffsetx, sideMenuWidth), 0) : 0
                offsetx = translationX
                calculateProgress()
            }
            .onEnded { value in
                guard value.startLocation.x > 10 else { return }

                withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                    let velocityX = value.velocity.width / 8
                    let total = velocityX + offsetx
                    
                    if total > (sideMenuWidth * 0.6) {
                        showSideBar()
                    }
                    else{
                        reset()
                    }
                    offsetx = 0
                }
            }
    }
    
    func showSideBar() {
        offsetx = sideMenuWidth
        lastOffsetx = offsetx
        showMenu = true
        calculateProgress()
    }
    
    func reset() {
        offsetx = 0
        lastOffsetx = 0
        showMenu = false
        calculateProgress()
    }
    
    func calculateProgress() {
        progress = max(min(offsetx / sideMenuWidth, 1), 0)
    }
}

#Preview {
    UpcomingOrders(orderManager: OrderManager.shared, inventoryManager: InventoryManager.shared)
}
