//
//  MainView.swift
//  My Orders
//
//  Created by שיראל זכריה on 27/11/2023.
//

import SwiftUI
import GoogleSignIn
import Firebase



struct MainView: View {
    
    @State private var showLogo = true
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
//    @StateObject var authService = AuthService()
//    init(){}

    var body: some View {

        ZStack {
            if showLogo {
                LaunchView()
                    .onAppear {
                        // Add any additional setup code if needed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showLogo = false
                            }
                        }
                    }
                if hasLaunchedBefore {
                    WelcomeView()
                        .onAppear {
                            hasLaunchedBefore = true
                            // Check if `user` exists; otherwise, do something with `error`
                            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                            }
                        }
                        .onOpenURL { url in
                                  GIDSignIn.sharedInstance.handle(url)
                                }
                }
            } else {
                ContentView()
            }
        }
    }
}

#Preview {
    MainView()
}
