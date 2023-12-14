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
    
    init() {
//        self.manager = Manager()
        loadManagerData()
//        requestNotificationAuthorization()
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
    
    private func saveManagerData() {
        if let encodedData = try? JSONEncoder().encode(manager) {
            UserDefaults.standard.set(encodedData, forKey: "manager")
            Toast.showToast(message: "Saved successfully")
        }
        else {
            Toast.showToast(message: "Error while saving")
        }
    }
    
//    func requestNotificationAuthorization() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if granted {
//                print("Notification authorization granted")
//            } else if let error = error {
//                print("Error requesting notification authorization: \(error.localizedDescription)")
//            }
//        }
//    }
    
    func setLanguage() {
        
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

