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
        let height = UIScreen.main.bounds.height - 32

        
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
                        else {
                            Toast.showToast(message: "We had an error signing you in")
                        }
                    }
                    
                }
                .sheet(isPresented: $isGoogleSignInSuccessful, content: {
                    UserRoleView()
//                    ContentView()
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
                .sheet(isPresented: $isAppleSignInSuccessful, content: {
                    UserRoleView()
//                    ContentView()
                })
                
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
//                    ContentView()
                    UserRoleView()
                })
                .padding()

                Text("Note: signing in with Google or Apple allows you to view your data through all your connected devices.")
                    .foregroundColor(.gray)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)

//                Text("Note: signing in with Google or Apple allows you to view your data through all your connected devices. And share your inventory items with your customers if you would like to.")


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

