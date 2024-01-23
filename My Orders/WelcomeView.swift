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
    
    @State private var isGuestButtonTapped = false
    @State private var isGoogleSignInSuccessful = false
    @State private var isAppleSignInSuccessful = false
    @EnvironmentObject var authState: AuthState
    
    var body: some View {
        
        let width = UIScreen.main.bounds.width - 32
        let height = UIScreen.main.bounds.height - 32

        
        NavigationStack {
            
            VStack {
                
                Image("aesthetic")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.top)
                
                VStack{
                    Text("Welcome!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("We are so happy to see you 🥳")
                }
                .padding(.top, 40)
                
                Spacer()

                Text("Choose an option:")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 40)
                                
                GoogleSiginBtn {
                    
                    AuthService.share.signinWithGoogle(presenting: getRootViewController(), authState: authState) { error in
                        // TODO: Handle ERROR
                        if error == nil && Auth.auth().currentUser != nil {
                            isGoogleSignInSuccessful = true
                        }
                        else {
                            Toast.showToast(message: "We had an error signing you in")
                        }
                    }
                                        
                }
                .navigationDestination(isPresented: $isGoogleSignInSuccessful, destination: {
                    UserRoleView()
                })
                .frame(minWidth: 0 , maxWidth: .infinity)
                .frame(height: 50)
                .padding()
                
                
                Button {
                    AuthService.share.startSignInWithAppleFlow()
                    
                    if Auth.auth().currentUser != nil {
                        isAppleSignInSuccessful = true
                    }
                    else {
                        Toast.showToast(message: "We had an error signing you in")
                    }
                    

                } label: {
                    AppleButtonView()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 50)
                        .cornerRadius(30)
                        .padding(.horizontal)
                        .shadow(color: .black.opacity(0.6), radius: 5, x: 0, y: 2)
                }
                .navigationDestination(isPresented: $isAppleSignInSuccessful, destination: {
                    UserRoleView()
                })
                
                Text("or")
                    .foregroundColor(.gray)
                    .padding()
                
                Button {
                    isGuestButtonTapped = true
                } label: {
                    Text("Continue as Guest")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(width: width, height: 50)
                        .foregroundColor(.white)
                        .background(Color.accentColor.opacity(0.9))
                        .cornerRadius(30)
                        .padding(.horizontal)
                }
                .navigationDestination(isPresented: $isGuestButtonTapped, destination: {
                    UserRoleView()
                })
                .padding()

                Text("Note: signing in with Google or Apple allows you to view your data through all your connected devices.")
                    .foregroundColor(.gray)
                    .padding([.leading, .trailing], 20)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: height / 7)
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

