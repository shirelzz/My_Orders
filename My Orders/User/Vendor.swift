//
//  Vendor.swift
//  My Orders
//
//  Created by שיראל זכריה on 22/01/2024.
//

import Foundation
import FirebaseAuth

enum VendorType: String, Codable {
    case food
    case beauty
    case other
    case none
}


struct Vendor: Codable, Identifiable {
    
    var id: String { uid }
    var uid: String
    var vendorType: VendorType
    var businessID: String
    var businessName: String
    var businessAddress: String
    var businessPhone: String
    
    init() {
        self.uid = UUID().uuidString
        self.vendorType = VendorType.none
        self.businessID = ""
        self.businessName = ""
        self.businessAddress = ""
        self.businessPhone = ""
    }
    
    init(uid: String, vendorType: VendorType, businessID: String, businessName: String , businessAddress: String , businessPhone: String){
        self.uid = uid
        self.vendorType = vendorType
        self.businessID = businessID
        self.businessName = businessName
        self.businessAddress = businessAddress
        self.businessPhone = businessPhone
    }
    
    func dictionaryRepresentation() -> [String: Any] {

        var vendorDict: [String: Any] = [
            
            "uid": uid,
            "vendorType": vendorType.rawValue,
            "businessID": businessID,
            "businessName": businessName,
            "businessAddress": businessAddress,
            "businessPhone": businessPhone

        ]
        
        return vendorDict
    }
    
    init?(dictionary: [String: Any]) {
        guard
            let uid = dictionary["uid"] as? String,
            let vendorTypeRawValue = dictionary["vendorType"] as? String,
            let vendorType = VendorType(rawValue: vendorTypeRawValue),
            let businessID = dictionary["businessID"] as? String,
            let businessName = dictionary["businessName"] as? String,
            let businessAddress = dictionary["businessAddress"] as? String,
            let businessPhone = dictionary["businessPhone"] as? String

        else {
            return nil
        }

        self.uid = uid
        self.vendorType = vendorType
        self.businessID = businessID
        self.businessName = businessName
        self.businessAddress = businessAddress
        self.businessPhone = businessPhone
    }

}

class VendorManager: ObservableObject {
    
    static var shared = VendorManager()
    @Published var vendor: Vendor = Vendor()
    private var isUserSignedIn = Auth.auth().currentUser != nil
    
    init() {
        if isUserSignedIn{
            fetchVendorFromDB()
        }
        else{
            loadVendorFromUD()
        }
    }
    
    func saveVendor(vendor: Vendor) {
        self.vendor = vendor
        if isUserSignedIn{
            saveVendor2DB(vendor)
        }
        else{
            saveVendor2UD()
        }
    }
    
    func getVendor() -> Vendor {
        return vendor
    }
    
    func updateVendor(businessID: String, businessName: String , businessAddress: String , businessPhone: String) {
        vendor.businessID = businessID
        vendor.businessName = businessName
        vendor.businessAddress = businessAddress
        vendor.businessPhone = businessPhone
        
        if isUserSignedIn {
            updateVendorInDB()
        }
        else{
            saveVendor2UD()
        }
    }
    
    func fetchVendorFromDB() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/vendorManager"

            DatabaseManager.shared.fetchVendor(path: path, completion: { vendor in
                DispatchQueue.main.async {
                    self.vendor = vendor ?? Vendor()
                    print("Success fetching vendor")
                }
            })
        }
    }
    
    private func saveVendor2DB(_ vendor: Vendor) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/vendorManager"
            DatabaseManager.shared.saveVendor(vendor, path: path)
        }
    }
    
    private func updateVendorInDB() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/vendorManager"
            DatabaseManager.shared.updateVendorInDB(vendor, path: path) { success in
                if !success {
                    print("updating in the database failed (updateVendorInDB)")
                }
            }
        }
    }
    
    // MARK:  user defaults (guest users)
    
    private func saveVendor2UD() {
        
        let vendorDict: [String: Any] = [
            "uid": vendor.uid,
            "vendorType": vendor.vendorType.rawValue,
            "businessID": vendor.businessID,
            "businessName": vendor.businessName,
            "businessAddress": vendor.businessAddress,
            "businessPhone": vendor.businessPhone
            
        ]
        
        // Save the dictionary to UserDefaults
        UserDefaults.standard.set(vendorDict, forKey: "vendor")
        
        print("Vendor saved to UserDefaults")
    }

    func loadVendorFromUD() {
        
        if let vendorDict = UserDefaults.standard.dictionary(forKey: "vendor") {
            if let vendor = Vendor(dictionary: vendorDict) {
                self.vendor = vendor
                print("Vendor loaded from UserDefaults")
            }
        }
    }
    
}
