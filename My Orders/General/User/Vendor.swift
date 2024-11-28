//
//  Vendor.swift
//  My Orders
//
//  Created by שיראל זכריה on 22/01/2024.
//

import Foundation
import FirebaseAuth

//enum VendorType: String, Codable {
//    case food
//    case beauty
//    case other
//    case none
//}


struct Vendor: Codable, Identifiable {
    
    var id: String { uid }
    var uid: String
    var businessID: String
    var businessName: String
    var businessAddress: String
    var businessPhone: String
    var businessDiaplayName: String

    init() {
        self.uid = UUID().uuidString
        self.businessID = ""
        self.businessName = "nullName"
        self.businessAddress = ""
        self.businessPhone = ""
        self.businessDiaplayName = ""
    }
    
    init(uid: String, businessID: String, businessName: String , businessAddress: String , businessPhone: String, businessDiaplayName: String){
        self.uid = uid
        self.businessID = businessID
        self.businessName = businessName
        self.businessAddress = businessAddress
        self.businessPhone = businessPhone
        self.businessDiaplayName = businessDiaplayName
        
    }
    
    func dictionaryRepresentation() -> [String: Any] {

        let vendorDict: [String: Any] = [
            
            "uid": uid,
            "businessID": businessID,
            "businessName": businessName,
            "businessAddress": businessAddress,
            "businessPhone": businessPhone,
            "businessDiaplayName": businessDiaplayName

        ]
        
        return vendorDict
    }
    
    init?(dictionary: [String: Any]) {
        guard
            let uid = dictionary["uid"] as? String,
            let businessID = dictionary["businessID"] as? String,
            let businessName = dictionary["businessName"] as? String,
            let businessAddress = dictionary["businessAddress"] as? String,
            let businessPhone = dictionary["businessPhone"] as? String,
            let businessDiaplayName = dictionary["businessDiaplayName"] as? String

        else {
            return nil
        }

        self.uid = uid
        self.businessID = businessID
        self.businessName = businessName
        self.businessAddress = businessAddress
        self.businessPhone = businessPhone
        self.businessDiaplayName = businessDiaplayName
    }

}

class VendorManager: ObservableObject {
    
    static var shared = VendorManager()
    @Published var vendor: Vendor = Vendor()
    private var isUserSignedIn = Auth.auth().currentUser != nil
    
    init() {
        if isUserSignedIn{
            fetchVendorFromDB()
            print("--- vendor name: \(vendor.businessName)")
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
    
    func updateVendor(businessID: String, businessName: String , businessAddress: String, businessPhone: String) {
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
    
//    func updateVendorDisplayedName(businessDisplayedName: String) {
//        self.vendor.businessDiaplayName = businessDisplayedName
//        if isUserSignedIn {
//            updateVendorInDB()
//            updateVendorDisplayedNameInDB(name: businessDisplayedName)
//        }
//    }
    
    func fetchVendorFromDB() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/vendorManager"

            VendorDatabaseManager.shared.fetchVendor(path: path, completion: { vendor in
                DispatchQueue.main.async {
                    self.vendor = vendor ?? Vendor()
                    print("Success fetching vendor")
                }
            })
        }
    }
    
    func getWorkingHoursFromDB() -> [WorkingDay] {
        var hours: [WorkingDay] = []
        let path = "vendors/\(vendor.id)/businessHours"
        VendorDatabaseManager.shared.fetchWorkingHours(path: path, completion: { fetchedHours in
            DispatchQueue.main.async {
                hours = fetchedHours
            }
        })
        return hours
    }

    private func saveVendor2DB(_ vendor: Vendor) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/vendorManager"
            VendorDatabaseManager.shared.saveVendor(vendor, path: path)
        }
    }
    
    func saveVendorDisplayedName(_ name: String, vendorID: String) {
        if Auth.auth().currentUser != nil {
            let path = "vendors/\(vendorID)/name"
            VendorDatabaseManager.shared.saveVendorDisplayedName(name, path: path)
        }
    }
    
    func saveBusinessHours(businessHours: [WorkingDay]) {
        if Auth.auth().currentUser != nil {
            let path = "vendors/\(vendor.id)/businessHours"
            VendorDatabaseManager.shared.saveBusinessHours(businessHours, path: path)
        }
    }
        
    private func updateVendorInDB() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/vendorManager"
            VendorDatabaseManager.shared.updateVendorInDB(vendor, path: path) { success in
                if !success {
                    print("updating in the database failed (updateVendorInDB)")
                }
            }
        }
    }
    
//    private func updateVendorDisplayedNameInDB(name: String) {
//        if let currentUser = Auth.auth().currentUser {
//            let vendorsPath = "vendors/\(vendor.id)"
//            DatabaseManager.shared.saveVendorDisplayedName(name: name, path: vendorsPath, completion: { success in
//                if !success {
//                    print("updating in the database failed (updateVendor name InDB)")
//                }
//            })
//        }
//    }
    
    // MARK:  user defaults (guest users)
    
    private func saveVendor2UD() {
        
        let vendorDict: [String: Any] = [
            "uid": vendor.uid,
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

