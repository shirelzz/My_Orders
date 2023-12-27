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
        bannerView.rootViewController = UIApplication.shared.windows.first?.rootViewController
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
        
        // Load the app open ad
        GADAppOpenAd.load(
            withAdUnitID: "ca-app-pub-3940256099942544/5575463023",
            request: GADRequest(),
            orientation: UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .unknown
        ) { (ad, error) in
            if let error = error {
                print("Failed to load app open ad with error: \(error.localizedDescription)")
                return
            }
            // ca-app-pub-3940256099942544/5575463023 // test

            
            if let appOpenAd = ad {
                appOpenAd.fullScreenContentDelegate = context.coordinator
                
                do {
                    try appOpenAd.present(fromRootViewController: adViewController)
                } catch {
                    print("Failed to present app open ad with error: \(error.localizedDescription)")
                }
            }
        }
        
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


//struct RewardedAdView: UIViewControllerRepresentable {
//    typealias UIViewControllerType = UIViewController
//    
//    let adUnitID: String
//    let rewardedAd: GADRewardedAd?
//    let onAdDismissed: () -> Void
//    
//    init(adUnitID: String, onAdDismissed: @escaping () -> Void) {
//        self.adUnitID = adUnitID
//        self.rewardedAd = GADRewardedAd(adUnitID: adUnitID)
//        self.onAdDismissed = onAdDismissed
//        loadRewardedAd()
//    }
//    
//    private func loadRewardedAd() {
//        rewardedAd?.load(GADRequest()) { error in
//            if let error = error {
//                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func makeUIViewController(context: Context) -> UIViewController {
//        let adViewController = UIViewController()
//        
//        if let rewardedAd = rewardedAd {
//            rewardedAd.present(fromRootViewController: adViewController) {
//                self.onAdDismissed()
//            }
//        }
//        
//        return adViewController
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        // No need to implement anything here
//    }
//}


import GoogleMobileAds
import SwiftUI

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
