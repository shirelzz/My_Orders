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
import BackgroundTasks
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
        scheduleNotificationsBackgroundTask()
        scheduleOrderNotifications()

        return true
    }
    
    func scheduleNotificationsBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: "orderNotifications")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // Run every hour
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Error scheduling background task: \(error)")
        }
    }
    
    func scheduleOrderNotifications() {
        let orderManager = OrderManager.shared
        let notificationManager = NotificationManager.shared
        
        let upcomingOrders = orderManager.getUpcomingOrders()
        
        for order in upcomingOrders {
            notificationManager.scheduleOrderNotification(order: order)
        }
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
    
    @StateObject private var authState = AuthState()


//    @ObservedObject var router = Router()
    
    var body: some Scene {
        WindowGroup {
                MainView()
                    .environmentObject(OrderManager.shared)
                    .environmentObject(authState)
                    .environmentObject(UserManager.shared)
                    .environmentObject(VendorManager.shared)
                    .onAppear {
                        // Ensure Firebase is configured only once
                        if FirebaseApp.app() == nil {
                            FirebaseApp.configure()
                        }
                        
                        authState.isAuthenticated = Auth.auth().currentUser != nil
                    }
            
//            NavigationStack(path: $router.navPath) {
//                MainViewOther()
//                    .navigationDestination(for: Router.Destination.self) { destination in
//                        switch destination {
//                            
//                        case .welcome:
//                            WelcomeView()
//                            
//                        case .userRole:
//                            UserRoleView()
//                            
//                        case .contentView:
//                            ContentView()
//                            
//                        case .customerContent:
//                            CustomerContentView()
//                            
//                        case .vendorType:
//                            Text("vendorType")
//                        case .bussinessDetailsView:
//                            Text("bussinessDetailsView")
//                            
//                        }
//                    }
//                    .environmentObject(router)
//                    .environmentObject(OrderManager.shared)
//                    .environmentObject(authState)
//                    .onAppear {
//                        // Ensure Firebase is configured only once
//                        if FirebaseApp.app() == nil {
//                            FirebaseApp.configure()
//                        }
//                        
//                        authState.isAuthenticated = Auth.auth().currentUser != nil
//                    }
//            }
        }
    }
}
