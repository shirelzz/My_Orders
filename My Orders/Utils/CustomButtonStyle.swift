//
//  CustomButtonStyle.swift
//  My Orders
//
//  Created by שיראל זכריה on 14/01/2024.
//

import Foundation
import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let width = UIScreen.main.bounds.width - 32

        configuration.label
            .foregroundColor(configuration.isPressed ? .white : .accentColor)
            .background(configuration.isPressed ? Color.accentColor.opacity(0.8) : Color.white)
            .frame(minWidth: 0 , maxWidth: .infinity)
            .frame(width: width, height: 50)
            .cornerRadius(30)
            .padding(.horizontal)
            .padding()
    }
}
