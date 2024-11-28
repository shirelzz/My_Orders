//
//  Customer.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/01/2024.
//

import Foundation
import FirebaseAuth

struct CustomerUser: Codable {
    
    var id: String
    var following: [String]
    
}

struct Business: Codable {
    
    var id: String
    var name: String
    //var items: [InventoryItem]?
    
    init() {
        self.id = ""
        self.name = ""
        //self.items = []
    }
    
    init(id: String, name: String) { //, items: [InventoryItem]
        self.id = id
        self.name = name
        //self.items = []
    }
    
    func dictionaryRepresentation() -> [String: Any] {
        
        let businessDict: [String: Any] = [
            
            "id": id,
            "name": name //,
            //"items": items

        ]
        
        return businessDict
    }
    
    init?(dictionary: [String: Any]) {
        
        guard let id = dictionary["id"] as? String,
              let name = dictionary["name"] as? String //,
              //let items = dictionary["items"] as? Double
        else {
            return nil
        }
        self.id = id
        self.name = name
        //self.items = items
    }
    
}

class CustomerManager: ObservableObject {
    
    static let shared = CustomerManager()
    @Published var listOfBus: [Business] = []
    @Published var vendorItems: [InventoryItem] = []
    
    init() {
        if UserManager.shared.user.role == .customer {
            fetchBusinesses()
        }
    }
    
    func saveBusiness2Db(_ business: Business) {
        print("in saveBusiness2Db")
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            print("userID \(userID)")
            let path = "users/\(userID)/businesses"
            CustomerDatabaseManager.shared.saveBusiness(business, path: path)
        }
    }
    
    func fetchBusinesses() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/businesses"
            
            CustomerDatabaseManager.shared.fetchBusinesses(path: path) { fetchedBuss in
                DispatchQueue.main.async {
                    self.listOfBus = fetchedBuss
                }
            }
        }

    }
    
    
    
    func fetchBusinessDiaplayName(vandorID: String, completion: @escaping (String) -> Void) {
        if Auth.auth().currentUser != nil {
            let path = "vendors/\(vandorID)/name"
            
            VendorDatabaseManager.shared.fetchVendorName(path: path) { fetchedName in
                DispatchQueue.main.async {
                    completion(fetchedName)
                }
            }
        }
    }
    
    func getBusinessDiaplayName(vandorID: String) -> String {
        var name = ""
        let path = "vendors/\(vandorID)/name"
        
        VendorDatabaseManager.shared.fetchVendorName(path: path) { fetchedName in
            DispatchQueue.main.async {
                name = fetchedName
            }
        }
        return name
    }
    
//    func fetchItemsForVendorID(_ vendorID: String) {
//        let path = "vendors/\(vendorID)"
//
//        DatabaseManager.shared.fetchItems(path: path) { fetchedItems in
//            DispatchQueue.main.async {
//                self.vendorItems = fetchedItems
//                // Update your UI to display fetchedItems
//                print("Success fetching items for vendor ID \(vendorID)")
//            }
//        }
//    }
    
    func getItemsForVendorID(_ vendorID: String) -> [InventoryItem] {
        let path = "vendors/\(vendorID)/items"
        
        InventoryDatabaseManager.shared.fetchItems(path: path) { fetchedItems in
            DispatchQueue.main.async {
                self.vendorItems = fetchedItems
                // Update your UI to display fetchedItems
                print("Success fetching items for vendor ID \(vendorID)")
            }
        }
        
        return self.vendorItems
    }
    
    func getWorkingHoursFromDB(vendorID: String, completion: @escaping ([WorkingDay]) -> Void) {
        let path = "vendors/\(vendorID)/businessHours"
        VendorDatabaseManager.shared.fetchWorkingHours(path: path, completion: { fetchedHours in
            DispatchQueue.main.async {
                completion(fetchedHours)
            }
        })
    }

    
    func getBusinesses() -> [Business] {
        return listOfBus
    }
    
    func deleteBus(busID: String) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/businesses"
            CustomerDatabaseManager.shared.deleteBusiness(vendorID: busID, path: path)
        }
    }
}


class BusinessManager: ObservableObject {
    
    static let shared = BusinessManager()
    @Published var list: [Business] = []
    
    func getBusinesses() -> [Business] {
        return list
    }
    
    func deleteBus(busID: String) {
    }
    
}
