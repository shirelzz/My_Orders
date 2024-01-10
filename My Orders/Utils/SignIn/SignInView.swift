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
        
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authState: AuthState


    var body: some View {
        
        NavigationView {
            
            VStack {
                
                Spacer()

                Text("Choose an option:")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 40)
                
                GoogleSiginBtn {
                    
                    print("---> User pressed")

                    
                    AuthService.share.signinWithGoogle(presenting: getRootViewController(), authState: authState) { error in
                        // TODO: Handle ERROR
                        if error != nil {
                            Toast.showToast(message: "error signing you in")
                            print("---> User is not signed in")
                        }
                        else {
                            print("---> User is signed in with google")
                            authState.isAuthenticated = true
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    
//                    if authState.isAuthenticated {
//                        print("---> User signed in")
//                        presentationMode.wrappedValue.dismiss()
//                    }
                
                }
                .frame(minWidth: 0 , maxWidth: .infinity)
                .frame(height: 50)
                .padding()
                .onChange(of: authState.isAuthenticated) { isAuthenticated in
                    if isAuthenticated {
                        print("---> here 1")
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                

                Text("or")
                    .foregroundColor(.gray)
                    .padding()
                
                Button {
                    AuthService.share.startSignInWithAppleFlow()

                    DispatchQueue.main.async {
                        authState.isAuthenticated = true
                    }
                } label: {
                    AppleButtonView()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 50)
                        .cornerRadius(30)
                        .padding(.horizontal)
                        .shadow(color: .black.opacity(0.6), radius: 5, x: 0, y: 2)
                }
                .onChange(of: authState.isAuthenticated) { isAuthenticated in
                    if isAuthenticated {
                        print("---> here 1")
                        presentationMode.wrappedValue.dismiss()
                    }
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
            .onDisappear {
                print("---> SignInView disappeared")
            }
            .onAppear {
                print("---> SignInView appeared")
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}


