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
//    @StateObject private var userManager = UserManager.shared
    @StateObject private var vendorManager = VendorManager.shared
    
    @State private var showVendorContentView = false
    @State private var showCustomerContentView = false
    @State private var showUserRoleView = false
    
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
                                                
                        if UserManager.shared.user.id != "" {
                            if UserManager.shared.user.role.rawValue == UserRole.vendor.rawValue || showVendorContentView {
                                ContentView()
                                    .navigationBarHidden(true)
                            }
                            else if UserManager.shared.user.role.rawValue == UserRole.customer.rawValue || showCustomerContentView {
                                CustomerContentView()
                                    .navigationBarHidden(true)
                            }
                            else if UserManager.shared.user.role.rawValue == UserRole.none.rawValue || showUserRoleView {
                                UserRoleView()
                                    .navigationBarHidden(true)
                                    .onAppear(perform: {
                                        print("--- going to UserRoleView 1")
                                    })
                            }
                        }
                    }
                }
                .onAppear {
                    if hasLaunchedBefore {
                        DispatchQueue.main.async {
                            showContentView = true
                        }
                    }
                    
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
