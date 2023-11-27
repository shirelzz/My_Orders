//
//  AppManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import Foundation
import SwiftUI

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
    @Published var manager: Manager
    
    init() {
        self.manager = Manager()
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
    
    private func saveManagerData() {
        if let encodedData = try? JSONEncoder().encode(manager) {
            UserDefaults.standard.set(encodedData, forKey: "manager")
            Toast.showToast(message: "Saved successfully")
        }
        else {
            Toast.showToast(message: "Error while saving")
        }
    }
    
}

