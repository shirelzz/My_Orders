//
//  AppManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import Foundation
import SwiftUI
import UserNotifications


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
    @Published var isUserSignedIn = false
    
    init() {
        loadManagerData()
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
    
}

