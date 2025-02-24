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
                        
                        Section {
                        
                            if AppManager.shared.getPublicID() == "" {
                                Button("Create public code") {
                                    
                                    do {
                                        if let currentUser = Auth.auth().currentUser {
                                            let userID = currentUser.uid
                                            print("--> userID: \(userID)")
                                            let publicID = try Encryption.encryptID(userID: userID)
                                            print("--> publicID: \(publicID)")
                                            let decryptedPublicID = try Encryption.decryptID(encryptedID: publicID)
                                            print("--> decrypted: \(decryptedPublicID)")
                                            AppManager.shared.savePublicID(publicID: publicID)
                                        }
                                    } catch {
                                        print("Error encrypting ID: \(error)")
                                    }
                                }
                                .disabled(true)
                            
                            }
                            else {
                                
                                Button("Copy public code") {
                                    UIPasteboard.general.string = AppManager.shared.getPublicID()
                                }
                            }
                            
                           

                        } footer: {
                            Text("By sharing this code you allow clients view your public inventory items. Will be available soon.")
                        }
                        
                        Button("Sign Out") {
                            do {
                                try Auth.auth().signOut()
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
