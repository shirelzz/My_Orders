//
//  AccountView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI
import FirebaseAuth

//class AuthState: ObservableObject {
//    static var isAuthenticated = Auth.auth().currentUser != nil
//}

struct AccountView: View {
           
    @State private var showSignInView = false
    @EnvironmentObject var authState: AuthState
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        
        NavigationView {
            
            VStack {
                
                if authState.isAuthenticated {
                    Text("Welcome, \(Auth.auth().currentUser?.displayName ?? "User")!")
                        .font(.largeTitle)
                        .padding(.leading)
                    
                    List {
                        
                        Button("Sign Out") {
                            print("sign out pressed")
                            do {
                                try Auth.auth().signOut()
//                                AuthState.isAuthenticated = false
                                print("---> here 0")
                                authState.isAuthenticated = false
//                                presentationMode.wrappedValue.dismiss()
                                
                            } catch {
                                print("Error signing out: \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                                        
//                    List {
//                        Button("Sign In") {
//                            showSignInView.toggle()
//                        }
//                        .sheet(isPresented: $showSignInView) {
//                            SignInView()
//                        }
//                    }
                    
                    SignInView()
                    
//                    NavigationStack {
//                        
//                        List {
//                            NavigationLink(destination: SignInView()) {
//                                Text("Sign In")
//                            }
//                        }
//                    }
                }
            }
        }
        .navigationTitle("Account")
    }
}

#Preview {
    AccountView()
}
