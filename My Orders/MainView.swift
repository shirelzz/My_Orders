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
    @EnvironmentObject var authState: AuthState
    @StateObject private var userManager = UserManager.shared
    @StateObject private var vendorManager = VendorManager.shared
    @State private var userRole: UserRole = UserRole.none
    
    var body: some View {

        ZStack {
            if showLogo {
                LaunchView()
                    .onAppear {
                        
                        print("hasLaunchedBefore 0: \(hasLaunchedBefore)")

                        // Add any additional setup code if needed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                showLogo = false
                            }
                        }
                    }
                
            }
            else {
                
                NavigationView {
                    if !hasLaunchedBefore {
                        
                        if authState.isAuthenticated {
                            UserRoleView()
                                .navigationBarHidden(true)
                                .onAppear(perform: {
                                    print("--- going to UserRoleView 0")
                                })
                        }
                        
                        else {
                            WelcomeView()
                                .onAppear {
                                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                                    }
                                }
                                .onOpenURL { url in
                                    GIDSignIn.sharedInstance.handle(url)
                                }
                                .navigationBarHidden(true)
                        }
                       
                    } else {
                        
                        if userRole == UserRole.vendor {
                            ContentView()
                                .navigationBarHidden(true)
                        }
                        else if userRole == UserRole.customer {
                            CustomerContentView()
                                .navigationBarHidden(true)
                        }
                        else {
                            UserRoleView()
                                .navigationBarHidden(true)
                                .onAppear(perform: {
                                    print("--- going to UserRoleView 1")
                                })
                        }
                    }
                }
                .onAppear {
                    if hasLaunchedBefore {
                        DispatchQueue.main.async {
                            showContentView = true
                        }
                    }
                    
                    userRole = userManager.user.role
                }
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
