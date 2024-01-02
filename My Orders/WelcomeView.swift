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
    
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @State private var isGuestButtonTapped = false
    @State private var isGoogleSignInSuccessful = false
    @State private var isAppleSignInSuccessful = false
    @EnvironmentObject var authState: AuthState

    
    var body: some View {
        
        let guestWidth = UIScreen.main.bounds.width - 32
        
        NavigationView {
            VStack {
                
                Image("Desk2")
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
                            hasLaunchedBefore = true
                            isGoogleSignInSuccessful = true
                        }
                    }
                    
                }
                .sheet(isPresented: $isGoogleSignInSuccessful, content: {
                    ContentView()
                })
                .frame(minWidth: 0 , maxWidth: .infinity)
                .frame(height: 50)
                .padding()
                
                
                Button {
                    AuthService.share.startSignInWithAppleFlow()
                    
                    if Auth.auth().currentUser != nil {
                        hasLaunchedBefore = true
                        isAppleSignInSuccessful = true
                    }
                    

                } label: {
                    AppleButtonView()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 50)
                        .cornerRadius(30)
                        .padding(.horizontal)
                        .shadow(color: .black.opacity(0.6), radius: 5, x: 0, y: 2)
                }
                .sheet(isPresented: $isAppleSignInSuccessful, content: {
                    ContentView()
                })
                
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
                
                Button {
                           isGuestButtonTapped = true
                           
                           // Update hasLaunchedBefore to true when the user continues as a guest
                           hasLaunchedBefore = true
                       } label: {
                           Text("Continue as Guest")
                               .frame(minWidth: 0, maxWidth: .infinity)
                               .frame(width: guestWidth, height: 50)
                               .foregroundColor(.white)
                               .background(Color.accentColor.opacity(0.9))
                               .cornerRadius(30)
                               .padding(.horizontal)
                       }
                       .sheet(isPresented: $isGuestButtonTapped, content: {
                           ContentView()
                       })
                       .padding(.bottom, 40)

                Spacer(minLength: 60)
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

