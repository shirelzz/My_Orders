//
//  SideMenu.swift
//  My Orders
//
//  Created by שיראל זכריה on 02/12/2023.
//

import SwiftUI

struct SideMenu: View {
    
    @Binding var isShowing: Bool
    
    var content = ContentView()
    var edgeTransition: AnyTransition = .move(edge: .leading)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if (isShowing) {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowing.toggle()
                    }
                content
                    .transition(edgeTransition)
                    .background(
                        Color.white
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.easeInOut, value: isShowing)
    }
}

//#Preview {
//    SideMenu(isShowing: isShowing)
//}
