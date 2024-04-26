//
//  DatabaseManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 19/12/2023.
//

import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift
//
import Firebase
import Combine

class DatabaseManager {
    
//    static var shared = DatabaseManager()
    
    internal var databaseRef = Database.database().reference()
    
    internal func usersRef() -> DatabaseReference {
        return databaseRef.child("users")
    }
    
    // MARK: - Helper Functions
    
    func convertStringToDate(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
    func convertStringToDateAndTime(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //HH:mm
        return dateFormatter.date(from: dateString)
    }
    
    
    // MARK: - Deleting data
    
    func deleteItem(itemID: String, path: String) {
        let itemRef = databaseRef.child(path).child(itemID)
        itemRef.removeValue()
    }
    
    //i dont understand why the items quantity doesnt update when i delete an order

}
