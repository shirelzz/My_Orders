//
//  MyOrdersApp.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI
import Firebase
//import FirebaseCore
//import FirebaseMessaging
//import UserNotifications
//import BackgroundTasks
import GoogleSignIn
//import UIKit
//import GoogleMobileAds

@main
struct MyOrdersApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authState = AuthState()
    @StateObject private var userManager = UserManager.shared

    var body: some Scene {
        WindowGroup {
                MainView()
                    .environmentObject(OrderManager.shared)
                    .environmentObject(authState)
                    .environmentObject(userManager)
                    .environmentObject(VendorManager.shared)
                    .onAppear {
                        // Ensure Firebase is configured only once
                        if FirebaseApp.app() == nil {
                            FirebaseApp.configure()
                        }
                        
                        authState.isAuthenticated = Auth.auth().currentUser != nil
                    }
        }
    }
}
