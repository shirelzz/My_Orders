//
//  AccountView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI
import FirebaseAuth

struct AccountView: View {
    var body: some View {
        
        
        VStack {
            if Auth.auth().currentUser != nil {
                Text("Welcome, \(Auth.auth().currentUser?.displayName ?? "User")!")
                    .font(.largeTitle)
                    .padding(.leading)
                
                List{
                    Button("Sign Out") {
//                        do {
//                            try Auth.auth().signOut()
//                        } catch {
//                            print("Error signing out: \(error.localizedDescription)")
//                        }
                        AuthService.share.googleSignOut()
                    }
                }
            } else {
                
                NavigationStack{
                    
                    List{
                        NavigationLink(destination: SignInView()) {
                            Text("Sign In")
                        }
                    }
                }
            }
        }
        .navigationTitle("Account")
    }
}

#Preview {
    AccountView()
}
