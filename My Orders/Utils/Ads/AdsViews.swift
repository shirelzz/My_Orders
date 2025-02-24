//
//  AdsViews.swift
//  My Orders
//
//  Created by שיראל זכריה on 25/12/2023.
//

import Foundation
import GoogleMobileAds
import SwiftUI
import AVFoundation

struct AdBannerView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: 320, height: 50))) // Set your desired banner ad size
        bannerView.adUnitID = adUnitID
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        if let topViewController = window?.rootViewController {
            bannerView.rootViewController = topViewController
        }
        
// old:        bannerView.rootViewController = UIApplication.shared.windows.first?.rootViewController
        bannerView.load(GADRequest())
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}

struct AppOpenAdView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    let adUnitID: String
    
    func makeUIViewController(context: Context) -> UIViewController {
        let adViewController = UIViewController()
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        // Load the app open ad
        GADAppOpenAd.load(
            withAdUnitID: "ca-app-pub-3940256099942544/5575463023",
            request: GADRequest(),
            completionHandler: { (ad, error) in
                if let error = error {
                    print("Failed to load app open ad with error: \(error.localizedDescription)")
                    return
                }
                
                // Handle the ad if it successfully loads
                if let appOpenAd = ad {
                    appOpenAd.fullScreenContentDelegate = context.coordinator
                    appOpenAd.present(fromRootViewController: adViewController)
                }
            }
        )

//        GADAppOpenAd.load(
//            withAdUnitID: "ca-app-pub-3940256099942544/5575463023",
//            request: GADRequest(),
//            orientation: window?.windowScene?.interfaceOrientation ?? .unknown
//        ) { (ad, error) in
//            if let error = error {
//                print("Failed to load app open ad with error: \(error.localizedDescription)")
//                return
//            }
//            // ca-app-pub-3940256099942544/5575463023 // test
//
//            
//            if let appOpenAd = ad {
//                appOpenAd.fullScreenContentDelegate = context.coordinator
//                
//                do {
//                    appOpenAd.present(fromRootViewController: adViewController)
//                }
//            }
//        }
        
        return adViewController
    }
    
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No need to implement anything here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, GADFullScreenContentDelegate {
        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
            // Handle app open ad dismissal if needed
        }
    }
    
}

struct RewardedAdView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    let adUnitID: String
    @Binding var isPresented: Bool // Binding to control presentation

    func makeUIViewController(context: Context) -> UIViewController {
        let adViewController = UIViewController()

        // Load the rewarded ad when the view is created
        GADRewardedAd.load(withAdUnitID: adUnitID, request: GADRequest()) { ad, error in
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                return
            }

            // Store the loaded ad for later presentation
            context.coordinator.rewardedAd = ad
        }

        return adViewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Check if the ad is loaded and should be presented
        if isPresented, let rewardedAd = context.coordinator.rewardedAd {
            rewardedAd.present(fromRootViewController: uiViewController) {
                // Handle reward if the user completes the ad
                let reward = rewardedAd.adReward
                    print("Reward received: \(reward)")
                    // Grant in-app rewards to the user
                

                // Load a new ad for the next presentation
                GADRewardedAd.load(withAdUnitID: adUnitID, request: GADRequest()) { ad, error in
                    context.coordinator.rewardedAd = ad
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, GADFullScreenContentDelegate {
        var rewardedAd: GADRewardedAd?
        let parent: RewardedAdView

        init(_ parent: RewardedAdView) {
            self.parent = parent
        }

        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
            // Dismiss the view controller when the ad is dismissed
            parent.isPresented = false
        }
    }
}

//public extension UIApplication {
//    func currentUIWindow() -> UIWindow? {
//        let connectedScenes = UIApplication.shared.connectedScenes
//            .filter { $0.activationState == .foregroundActive }
//            .compactMap { $0 as? UIWindowScene }
//        
//        let window = connectedScenes.first?
//            .windows
//            .first { $0.isKeyWindow }
//
//        return window
//        
//    }
//}

//struct SceneConstants {
//    
//    func currentUIWindow() -> UIWindow? {
//        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
//        let window = self.windowScene?.windows.first
//        return window
//    }
//    
//}
