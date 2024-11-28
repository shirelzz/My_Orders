////
////  AppleButtonLogic.swift
////  My Orders
////
////  Created by שיראל זכריה on 12/12/2023.
////
//
//import Foundation
//import AuthenticationServices
//import SwiftUI
//import FirebaseAuth
//import CryptoKit
//
//public class AppleButtonLogic: NSObject {
//    
//    fileprivate var currentNonce: String?
////    @EnvironmentObject var authService: AuthService
//    
//    public func signIn() {
//        let nonce = randomNonceString()
//        currentNonce = nonce
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.email, .fullName]
//        request.nonce = sha256(nonce)
//        
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.performRequests()
//    }
//    
//    private func randomNonceString(length: Int = 32) -> String {
//      precondition(length > 0)
//      var randomBytes = [UInt8](repeating: 0, count: length)
//      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
//      if errorCode != errSecSuccess {
//        fatalError(
//          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
//        )
//      }
//
//      let charset: [Character] =
//        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
//
//      let nonce = randomBytes.map { byte in
//        // Pick a random character from the set, wrapping around if needed.
//        charset[Int(byte) % charset.count]
//      }
//
//      return String(nonce)
//    }
//    
//    @available(iOS 13, *)
//    private func sha256(_ input: String) -> String {
//      let inputData = Data(input.utf8)
//      let hashedData = SHA256.hash(data: inputData)
//      let hashString = hashedData.compactMap {
//        String(format: "%02x", $0)
//      }.joined()
//
//      return hashString
//    }
//}
//
//extension AppleButtonLogic: ASAuthorizationControllerDelegate {
//
//    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if let aapleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            guard let nonce = currentNonce else {
//                return
//            }
//            guard let appleIdToken = aapleIdCredential.identityToken else {
//                return
//            }
//            
//            guard let idTokenString = String(data: appleIdToken, encoding: .utf8) else {
//                return
//            }
//            
//            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
//            Auth.auth().signIn(with: credential) { result, error in
//                guard  error == nil else {
//                    return
//                }
//                
//                DispatchQueue.main.async {
//                    self.authService.isLoggedIn = true
//                }
//                
//            }
//        }
//    }
//}
