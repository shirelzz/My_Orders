//
//  MainView.swift
//  My Orders
//
//  Created by שיראל זכריה on 27/11/2023.
//

import SwiftUI
import GoogleSignIn
import Firebase
import Combine

struct MainView: View {
    
    @State private var showLogo = true
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @State private var showContentView = false

//    @StateObject var authService = AuthService()
//    init(){}

    var body: some View {

        ZStack {
            if showLogo {
                LaunchView()
                    .onAppear {
                        
                        print("hasLaunchedBefore0: \(hasLaunchedBefore)")

                        // Add any additional setup code if needed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                showLogo = false
                            }
                        }
                    }

//                if !hasLaunchedBefore {
//                    WelcomeView()
//                        .onAppear {
//                            print("hasLaunchedBefore1: \(hasLaunchedBefore)")
//                            hasLaunchedBefore = true
//                            print("hasLaunchedBefore2: \(hasLaunchedBefore)")
//                            // Check if `user` exists; otherwise, do something with `error`
//                            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
//                            }
//                        }
//                        .onOpenURL { url in
//                            GIDSignIn.sharedInstance.handle(url)
//                        }
//                }
//                else {
//                    AppOpenAdView(adUnitID: "ca-app-pub-3940256099942544/5575463023")
//                        .onAppear{
//                            print("hasLaunchedBefore3: \(hasLaunchedBefore)")
//                        }
//                    ContentView()
//                }
                
            }
            else {
//                AppOpenAdView(adUnitID: "ca-app-pub-3940256099942544/5575463023")
//                    .onAppear{
//                        print("hasLaunchedBefore4: \(hasLaunchedBefore)")
//                    }
//                ContentView()
                
                NavigationView {
                                   if !hasLaunchedBefore {
                                       WelcomeView()
                                           .onAppear {
                                               GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                                               }
                                           }
                                           .onOpenURL { url in
                                               GIDSignIn.sharedInstance.handle(url)
                                           }
                                           .navigationBarHidden(true)
                                   } else {
                                       ContentView()
                                           .navigationBarHidden(true)
                                   }
                               }
                               .onAppear {
                                   if hasLaunchedBefore {
                                       DispatchQueue.main.async {
                                           showContentView = true
                                       }
                                   }
                               }
                
//                if !hasLaunchedBefore {
//                    
//                    WelcomeView()
//                        .onAppear {
//                            print("hasLaunchedBefore1: \(hasLaunchedBefore)")
//                            
//                            // Check if `user` exists; otherwise, do something with `error`
//                            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
//                            }
//                            
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                hasLaunchedBefore = true
//                            }
//                            print("hasLaunchedBefore2: \(hasLaunchedBefore)")
//                        }
//                        .onOpenURL { url in
//                            GIDSignIn.sharedInstance.handle(url)
//                        }
//                        
//                }
//                else {
//                    AppOpenAdView(adUnitID: "ca-app-pub-3940256099942544/5575463023")
//                        .onAppear{
//                            print("hasLaunchedBefore3: \(hasLaunchedBefore)")
//                        }
//                    ContentView()
//                }
            }
        }
        .onReceive(Just(hasLaunchedBefore)) { _ in
            // Additional logic based on the updated value of hasLaunchedBefore
            print("hasLaunchedBefore Updated: \(hasLaunchedBefore)")
        }
    }
}

#Preview {
    MainView()
}
