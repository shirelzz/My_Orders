//
//  MyOrdersApp.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import GoogleSignIn
import UIKit
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initializetion code for firebase
        FirebaseApp.configure()
        
        // Initialize the Mobile Ads SDK
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // for push notifications
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            guard success else { return }
            print("success (notifications)")
        }
        
        application.registerForRemoteNotifications()

        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    
    // for push notifications
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token , error in
            guard let token = token else { return }
            print("token \(token)")
        }
    }
}

@main
struct MyOrdersApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(OrderManager.shared)
                .onAppear {
                    // Ensure Firebase is configured only once
                    if FirebaseApp.app() == nil {
                        FirebaseApp.configure()
                    }
                }

        }
    }
}
