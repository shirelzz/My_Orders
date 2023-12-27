////
////  ViewController.swift
////  My Orders
////
////  Created by שיראל זכריה on 26/12/2023.
////
//
//import Foundation
//import SwiftUI
//import GoogleMobileAds
//import UIKit
//
//struct AdMobRewardedAdView: UIViewControllerRepresentable {
//    
//    class Coordinator: NSObject, GADFullScreenContentDelegate {
//        var parent: AdMobRewardedAdView
//
//        init(parent: AdMobRewardedAdView) {
//            self.parent = parent
//        }
//
//        // Implement GADFullScreenContentDelegate methods as needed
//        // ...
//
//        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//            print("Ad did dismiss full screen content.")
//            // Load a new rewarded ad for the next use.
//            parent.loadRewardedAd()
//        }
//    }
//
//    private var viewController = UIViewController()
//    private var coordinator: Coordinator?
//
//    init() {
//        coordinator = Coordinator(parent: self)
//        viewController = UIViewController()
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        guard let coordinator = coordinator else {
//            fatalError("Coordinator not found.")
//        }
//        return coordinator
//    }
//
//    func makeUIViewController(context: Context) -> UIViewController {
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        // Update the view controller if needed
//    }
//
//    func showRewardedAd() {
//        coordinator?.parent.showRewardedAd()
//    }
//
//    func loadRewardedAd() {
//        coordinator?.parent.loadRewardedAd()
//    }
//}
//
//class ViewController: UIViewController, GADFullScreenContentDelegate {
//    private var rewardedAd: GADRewardedAd?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        loadRewardedAd()
//    }
//
//    func loadRewardedAd() {
//        let request = GADRequest()
//        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: request) { [self] ad, error in
//            if let error = error {
//                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
//                return
//            }
//            rewardedAd = ad
//            rewardedAd?.fullScreenContentDelegate = self
//        }
//    }
//
//    func showRewardedAd() {
//        if let ad = rewardedAd {
//            ad.present(fromRootViewController: self) {
//                let reward = ad.adReward
//                print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
//                // TODO: Reward the user.
//            }
//        } else {
//            print("Ad wasn't ready")
//        }
//    }
//
//    // MARK: - GADFullScreenContentDelegate
//
//    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
//        print("Ad did fail to present full screen content.")
//    }
//
//    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        print("Ad will present full screen content.")
//    }
//
//    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        print("Ad did dismiss full screen content.")
//        loadRewardedAd()  // Load a new rewarded ad for the next use.
//    }
//}
//
