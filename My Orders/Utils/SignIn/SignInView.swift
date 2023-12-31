//
//  SignInView.swift
//  My Orders
//
//  Created by שיראל זכריה on 12/12/2023.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import Firebase
import FirebaseAuth
import _AuthenticationServices_SwiftUI

struct SignInView: View {
    
//    @ObservedObject var authService: AuthService

    var body: some View {
        NavigationView {
            VStack {
                
                Spacer()
                
//                Text("Sign In")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .padding()

                Text("Choose an option:")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 40)
                                
                GoogleSiginBtn {
                    // TODO: - Call the sign method here
//                    FirebAuth.share.signinWithGoogle(presenting: getRootViewController()) { error in
//                        // TODO: Handle ERROR
//                    }
                    
                    AuthService.share.signinWithGoogle(presenting: getRootViewController()) { error in
                        // TODO: Handle ERROR
                    }
                }
                .padding()

                Text("or")
                    .foregroundColor(.gray)
                    .padding()
                
                Button {
                    AuthService.share.startSignInWithAppleFlow()
                } label: {
                    AppleButtonView()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 50)
                        .padding(.horizontal)
                }
                
//                Button {} label: {
//                    AppleButtonView()
//                        .frame(width: 250, height: 50)
//                }
//                .padding()
                
//                SignInWithAppleButton(.signIn) { request in
//                    request.reqestedScopes = [.fullName, .email]
//                } onCompletion: { result in
//                    switch result {
//                        case .success(let authResults):
//                            print("Authorisation successful")
//                        case .error(let error):
//                            print("Authorisation failed: \(error.localizedDescription)")
//                    }
//                }
//                // black button
//                .signInWithAppleButtonStyle(.black)

                Spacer()
            }
            .navigationTitle("Sign In")
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}


