//
//  AuthService.swift
//  My Orders
//
//  Created by שיראל זכריה on 12/12/2023.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import CryptoKit
import AuthenticationServices
import GoogleSignIn

class AuthService: NSObject, ObservableObject, ASAuthorizationControllerDelegate  {
    
    @Published var signedIn:Bool = false
    
    static let share = AuthService()
    
    
    // Unhashed nonce.
    var currentNonce: String?
    
    override init() {
        super.init()
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                self.signedIn = true
                print("Auth state changed, is signed in")
            } else {
                self.signedIn = false
                print("Auth state changed, is signed out")
            }
        }
    }
    
    // MARK: - Password Account
    // Create, sign in, and sign out from password account functions...
    
    //MARK: - Apple sign in
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    // Single-sign-on with Apple
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
       
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error?.localizedDescription ?? "error")
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
                print("Apple sign in!")
                
                // Allow proceed to next screen
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    
    // Apple sign in...

    //from the same creator of applesignin but had to fix some problems
    func googleSignIn() {
        
          guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

          guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
          guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

          // Start the sign in flow!
          GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { authentication, error in

            if let error = error {
                print("Error doing Google Sign-In, \(error)")
                return
            }

            guard let user = authentication?.user, let idToken = user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
              
              
              // Authenticate with Firebase
              Auth.auth().signIn(with: credential) { authResult, error in
                  if let e = error {
                      print(e.localizedDescription)
                  }
                 
                  print("Signed in with Google")
              }
          }
      }
    
    // worked. from FireBAuth
    func signinWithGoogle(presenting: UIViewController,
                          completion: @escaping (Error?) -> Void) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { authentication, error in
            if let error = error {
                print("There is an error signing the user in ==> \(error)")
                return
            }
            guard let user = authentication?.user, let idToken = user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                guard error == nil else {
                    completion(error)
                    return
                }
                print("SIGN IN")
                UserDefaults.standard.set(true, forKey: "signIn") // When this change to true, it will go to the home screen
            }
        }
    }
    
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }

        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }

        return root
    }
    
    func googleSignOut() {
        GIDSignIn.sharedInstance.signOut()
        print("Google sign out")
    }
}
