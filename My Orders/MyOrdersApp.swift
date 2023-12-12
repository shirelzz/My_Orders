//
//  MyOrdersApp.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

import UIKit
import Firebase

//class AppDelegate: NSObject, UIApplicationDelegate{
//    func application(_ application: UIApplication,
//                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
//    {
//        FirebaseApp.configure()
//        return true
//    }
    
//    func application(
//      _ app: UIApplication,
//      open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
//    ) -> Bool {
//      var handled: Bool
//
//      handled = GIDSignIn.sharedInstance.handle(url)
//      if handled {
//        return true
//      }
//
//      // Handle other custom URL types.
//
//      // If not handled by this app, return false.
//      return false
//    }
//    
//    func application(
//      _ application: UIApplication,
//      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//    ) -> Bool {
//      GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
//        if error != nil || user == nil {
//          // Show the app's signed-out state.
//        } else {
//          // Show the app's signed-in state.
//        }
//      }
//      return true
//    }
//    
//    // firebase doc
//    func application(_ app: UIApplication,
//                     open url: URL,
//                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//      return GIDSignIn.sharedInstance.handle(url)
//    }
    
    // 12 min video
    
    
//    // https://medium.com/@kennjthn12/authentication-using-google-sign-in-with-swift-31039941dabf
//    func application(_ app: UIApplication,
//                     open url: URL,
//                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        return GIDSignIn.sharedInstance.handle(url)
//    }
//    
//    func application(_ application: UIApplication,
//                     didFinishLaunchingWithOptions launchOptions:
//                     [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // ...
//        
//        FirebaseApp.configure()
//        return true
//    }
//}

//
//  AppDelegate.swift
//  SignInUsingGoogle
//
//  Created by Swee Kwang Chua on 12/5/22.
//

//import UIKit
//import Firebase
//import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initializetion code for firebase
        FirebaseApp.configure()
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct MyOrdersApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let orderManager = OrderManager.shared

    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(orderManager)

        }
    }
}
