//
//  CustomButtonStyle.swift
//  My Orders
//
//  Created by שיראל זכריה on 14/01/2024.
//

import Foundation
import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    var isPressed: Bool

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
            .animation(.easeIn, value: 1)

    }
}

struct CustomButton: View {

let title: String
@Binding var isPressed: Bool
var action: () -> Void

var body: some View {
    let width = UIScreen.main.bounds.width - 32

    Button(action: {
        action()
    }) {
        Text(title)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(width: width, height: 50)
            .foregroundColor(isPressed ? .accentColor :  .white)
            .background(isPressed ? Color.white : Color.accentColor.opacity(0.9))
            .cornerRadius(30)
            .padding(.horizontal)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.accentColor, lineWidth: 1.5)
                    .frame(width: width, height: 50)
            )
    }
//    .buttonStyle(CustomButtonStyle(isPressed: isPressed))
}
}
