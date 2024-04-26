//
//  AppManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import Foundation
import SwiftUI
import UserNotifications
import FirebaseAuth

struct Manager: Codable {
    
    var logoImgData: Data?
    var signatureImgData: Data?
    
    enum CodingKeys: String, CodingKey {
        case logoImgData
        case signatureImgData
    }
}


class AppManager: ObservableObject {
    
    static var shared = AppManager()
    @Published var manager = Manager()
    @Published var isUserSignedIn = Auth.auth().currentUser != nil
    @Published var currency = "USD"
    private var publicID: String?

    init() {
        loadManagerData()
        if isUserSignedIn{
            fetchCurrencyFromDB()
            fetchPublicIDFromDB()
        }
        else{
            loadCurrencyFromUD()
        }
    }
    
    func saveCurrency(currency: String) {
        self.currency = currency
        if isUserSignedIn{
            print("---> saving currency 2DB: \(currency)")
            saveCurrency2DB(currency)
        }
        else{
            print("---> saving currency 2UD")
            saveCurrency2UD()
        }
    }
    
    func savePublicID(publicID: String) {
        self.publicID = publicID
        if isUserSignedIn{
            savePublicID2DB(publicID)
        }
    }
    
    // MARK: - Database

    func fetchCurrencyFromDB() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            print("Current UserID: \(userID)")
            let path = "users/\(userID)/currency"

            CurrencyDatabaseManager.shared.fetchCurrency(path: path, completion: { currency in
                DispatchQueue.main.async {
                    self.currency = currency
                    print("Success fetching currency: \(currency)")
                }
            })
        }
    }
    
    func saveCurrency2DB(_ currency: String) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/currency"
            CurrencyDatabaseManager.shared.saveCurrency(currency, path: path)
        }
    }
    
    func fetchPublicIDFromDB() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/publicID"

            UserDatabaseManager.shared.fetchPublicID(path: path, completion: { publicID in
                DispatchQueue.main.async {
                    if publicID != "" {
                        self.publicID = publicID
                        print("Success fetching publicID")
                    }
                }
            })
        }
    }
    
    func getPublicID() -> String {
        return self.publicID ?? ""
    }
    
    func savePublicID2DB(_ publicID: String) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/publicID"
            UserDatabaseManager.shared.savePublicID(publicID, path: path)
        }
    }
    
    // MARK: - User Defaults

    
    private func saveCurrency2UD() {
        UserDefaults.standard.set(currency, forKey: "selectedCurrency")
    }
    
    func loadCurrencyFromUD() {
        if let storedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") {
            self.currency = storedCurrency
        }
    }
    
    func currencySymbol(for code: String) -> String {
        switch code {
        case "USD":
            return "$"
        case "ILS":
            return "₪"
        case "EUR":
            return "€"
        case "GBP":
            return "£"
        default:
            return "$" // Default to "$" if the code is not recognized
        }
    }

    
    func saveManager(manager: Manager) {
        self.manager = manager
        saveManagerData()
    }
    
    func loadManagerData() {
        if let savedData = UserDefaults.standard.data(forKey: "manager"),
           let decodedManager = try? JSONDecoder().decode(Manager.self, from: savedData) {
            self.manager = decodedManager
        }
    }
    
    func saveManagerData() {
        if let encodedData = try? JSONEncoder().encode(manager) {
            UserDefaults.standard.set(encodedData, forKey: "manager")
            Toast.showToast(message: "Saved successfully")
        }
        else {
            Toast.showToast(message: "Error while saving")
        }
    }
    
    func updateManager(logoImageData: Data? = nil, signatureImageData: Data? = nil) {
            if let logoImageData = logoImageData {
                manager.logoImgData = logoImageData
            }
            
            if let signatureImageData = signatureImageData {
                manager.signatureImgData = signatureImageData
            }
            
            saveManagerData()
        }
    
    func getLogoImage() -> Image {
            if let logoImgData = manager.logoImgData,
               let logoImage = UIImage(data: logoImgData) {
                return Image(uiImage: logoImage)
            } else {
                return Image(systemName: "photo.on.rectangle")
            }
        }

        func getSignatureImage() -> Image {
            if let signatureImgData = manager.signatureImgData,
               let signatureImage = UIImage(data: signatureImgData) {
                return Image(uiImage: signatureImage)
            } else {
                return Image(systemName: "photo.on.rectangle")
            }
        }
    
    func getLogoImage() -> Data {
        if let logoImg = manager.logoImgData {
            return logoImg
        }
        else {
            print("error getting logo")
            return Data()
        }
    }
    
    func getSignatureImage() -> Data {
        if let signatureImg = manager.signatureImgData {
            return signatureImg
        }
        else {
            print("error getting signature")
            return Data()
        }
    }
    
    // MARK: - All Users

    func getCurrencySymbol() -> String {
        return self.currencySymbol(for: currency)
    }
    
    func refreshCurrency() {
        if isUserSignedIn{
            fetchCurrencyFromDB()
        }
        else{
            loadCurrencyFromUD()
        }
    }
}

