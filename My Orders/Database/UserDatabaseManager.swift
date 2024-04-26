//
//  UserDatabaseManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/04/2024.
//

import Foundation

class UserDatabaseManager: DatabaseManager {
    
    static var shared = UserDatabaseManager()
    
    // MARK: - Reading data
    
    func fetchPublicID(path: String, completion: @escaping (String) -> ()) {
        
        let publicIDRef = databaseRef.child(path)
        
        publicIDRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let publicID = snapshot.value as? String else {
                print("No publicID data found")
                completion("")
                return
            }
            
            completion(publicID)
        })
    }
    
    func fetchUser(path: String, completion: @escaping (User?) -> ()) {
          
        let userRef = databaseRef.child(path)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else {
                print("No user data found")
                completion(nil)
                return
            }

            var user: User?
            guard let userDict = snapshot.value as? [String: Any],
                      let uid = userDict["uid"] as? String,
                      let roleRawValue = userDict["role"] as? String,
//                      let vendorType = userDict["vendorType"] as? String
                      let role = UserRole(rawValue: roleRawValue)
            else{
                    print("Error parsing user data")
                    return
                }
            print("parsing user: \(uid)")
            print("parsing user: \(roleRawValue)")

            user = User(uid: uid, role: role) //, vendorType: VendorType.none

//                user = User(uid: uid, role: role, vendorType: VendorType(rawValue: vendorType ?? ""))
            
            completion(user)
        })
    }
    
    // MARK: - Writing data
    
    func savePublicID(_ publicID: String, path: String) {
        let publicIDRef = databaseRef.child(path)
        publicIDRef.setValue(publicID) { error, _ in
            if let error = error {
                print("Error saving publicID: \(error.localizedDescription)")
            } else {
                print("PublicID saved successfully")
            }
        }
    }
    
    func saveUser(_ user: User, path: String) {
        let userRef = databaseRef.child(path) //.child(user.id)
        userRef.setValue(user.dictionaryRepresentation()) { error, _ in
            if let error = error {
                print("Error saving user: \(error.localizedDescription)")
            } else {
                print("saved user")
            }
        }
    }
    
    
}
