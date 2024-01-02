//
//  AuthState.swift
//  My Orders
//
//  Created by שיראל זכריה on 02/01/2024.
//

import Foundation

class AuthState: ObservableObject {
    @Published var isAuthenticated = false

//    @Published var isAuthenticated = Auth.auth().currentUser != nil
}
