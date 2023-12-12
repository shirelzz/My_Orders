//
//  WelcomeView.swift
//  My Orders
//
//  Created by שיראל זכריה on 10/12/2023.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import Firebase
import FirebaseAuth

struct WelcomeView: View {
    
//    @ObservedObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            VStack {
                
                Spacer()
                
                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Text("Choose an option:")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 40)
                                
                GoogleSiginBtn {
//                    FirebAuth.share.signinWithGoogle(presenting: getRootViewController()) { error in
//                        // TODO: Handle ERROR
//                    }
                    
                    AuthService.share.signinWithGoogle(presenting: getRootViewController()) { error in
                        // TODO: Handle ERROR
                    }
                }
                .padding()
                
                Button {
                    AuthService.share.startSignInWithAppleFlow()
                } label: {
                    AppleButtonView()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 50)
                        .padding(.horizontal)
                }
                
//                Button {
//                    appleButton.signIn()
//                } label: {
//                    AppleButtonView()
//                        .frame(minWidth: 0, maxWidth: .infinity)
//                        .frame(height: 50)
//                        .padding(.horizontal)
//                }
//                .padding()
                
                Text("or")
                    .foregroundColor(.gray)
                    .padding()
                
                NavigationLink(destination: ContentView()) {
                    Text("Continue as Guest")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding()

                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}

