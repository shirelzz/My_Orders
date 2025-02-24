//
//  AppleButtonView.swift
//  My Orders
//
//  Created by שיראל זכריה on 12/12/2023.
//

import Foundation
import AuthenticationServices
import SwiftUI
import UIKit

struct AppleButtonView: UIViewRepresentable {
    typealias UIViewType = ASAuthorizationAppleIDButton
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let authorization = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        return authorization
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
}

#Preview {
    AppleButtonView()
}
