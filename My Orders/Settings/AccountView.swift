//
//  AccountView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI
import FirebaseAuth

struct AccountView: View {
           
    @State private var showSignInView = false
    @EnvironmentObject var authState: AuthState

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        
        NavigationView {
            
            VStack {
                
                if authState.isAuthenticated {
                    Text("Welcome \(Auth.auth().currentUser?.displayName ?? "")!")
                        .font(.largeTitle)
                        .padding(.leading)
                    
                    List {
                        
                        Button("Sign Out") {
                            print("sign out pressed")
                            do {
                                try Auth.auth().signOut()
                                print("---> here 0")
                                authState.isAuthenticated = false
                                
                            } catch {
                                print("Error signing out: \(error.localizedDescription)")
                            }
                        }
                        
                    }
                } else {
                    SignInView()
                }
                
                
            }
        }
        .navigationTitle("Account")
    }
}

#Preview {
    AccountView()
}
