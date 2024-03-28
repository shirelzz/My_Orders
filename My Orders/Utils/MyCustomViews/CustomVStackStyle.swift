//
//  CustomVStackStyle.swift
//  My Orders
//
//  Created by שיראל זכריה on 17/03/2024.
//

import SwiftUI

import SwiftUI

struct CustomVStackStyle: ViewModifier {
    var backgroundColor: Color
    var cornerRadius: CGFloat
    var shadowRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(backgroundColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(radius: shadowRadius)
    }
}

struct CustomGraySectionVStyle: ViewModifier {

    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.1))
            )
    }
}

extension View {
    func customVStackStyle(backgroundColor: Color = .accentColor, cornerRadius: CGFloat = 15, shadowRadius: CGFloat = 2) -> some View {
        self.modifier(CustomVStackStyle(backgroundColor: backgroundColor, cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
    
    func CustomGraySectionVStyle() -> some View {
        self.modifier(CustomGraySectionVStyle())
    }
}
