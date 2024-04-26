//
//  CustomerDatabaseManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/04/2024.
//

import Foundation

class CustomerDatabaseManager: DatabaseManager {
    
    static var shared = CustomerDatabaseManager()
    
    // MARK: - Reading data
    
    func fetchBusinesses(path: String, completion: @escaping ([Business]) -> ()) {
      
        let businessesRef = databaseRef.child(path)
        
        businessesRef.observeSingleEvent(of: .value, with: { (snapshot) in
        guard let value = snapshot.value as? [String: Any] else {
                print("No items data found")
                completion([])
                return
            }
            
            var businesses = [Business]()
            for (_, busData) in value {
                guard let busDict = busData as? [String: Any],
                      let id = busDict["id"] as? String,
                      let name = busDict["name"] as? String
                else {
                    print("bus else called")
                    continue
                }
                
                let bus = Business(id: id, name: name)
                
                businesses.append(bus)
            }
            completion(businesses)
        })
    }
    
    // MARK: - Saving data

    func saveBusiness(_ business: Business, path: String) {
        let bussRef = databaseRef.child(path).child(business.id)
        bussRef.setValue(business.dictionaryRepresentation()) { error, _ in
            if let error = error {
                print("Error saving business: \(error)")
            } else {
                print("Business saved successfully")
            }
        }
    }
    
    // MARK: - Deleting data
    
    func deleteBusiness(vendorID: String, path: String) {
        let vendorRef = databaseRef.child(path).child(vendorID)
        vendorRef.removeValue()
    }
}
