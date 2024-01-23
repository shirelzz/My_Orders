//
//  User.swift
//  My Orders
//
//  Created by שיראל זכריה on 13/01/2024.
//

import Foundation
import FirebaseAuth

enum UserRole: String, Codable {
    case customer
    case vendor
    case none
}

struct User: Codable, Identifiable {
    
    var id: String { uid }
    var uid: String
    var role: UserRole
//    var vendorType: VendorType?
    
    init() {
        self.uid = UUID().uuidString
        self.role = UserRole.none
    }
    
    init(uid: String, role: UserRole){ //, vendorType: VendorType?
        self.uid = uid
        self.role = role
//        self.vendorType = vendorType
    }
    
    func dictionaryRepresentation() -> [String: Any] {

        var userDict: [String: Any] = [
            
            "uid": uid,
            "role": role.rawValue,

        ]
        
//        if let vendorTypeRawValue = vendorType?.rawValue {
//            userDict["vendorType"] = vendorTypeRawValue
//        }
        
        return userDict
    }
    
    init?(dictionary: [String: Any]) {
        guard
            let uid = dictionary["uid"] as? String,
            let roleRawValue = dictionary["role"] as? String,
            let role = UserRole(rawValue: roleRawValue)
        else {
            return nil
        }

//        let vendorTypeRawValue = dictionary["vendorType"] as? String
//        let vendorType = VendorType(rawValue: vendorTypeRawValue ?? "")

        self.uid = uid
        self.role = role
//        self.vendorType = vendorType
    }
    
    // MARK: - Codable methods

    enum CodingKeys: String, CodingKey {
        case uid
        case role
//        case vendorType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        uid = try container.decode(String.self, forKey: .uid)
        role = try container.decode(UserRole.self, forKey: .role)
//        vendorType = try container.decodeIfPresent(VendorType.self, forKey: .vendorType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(uid, forKey: .uid)
        try container.encode(role, forKey: .role)
//        try container.encodeIfPresent(vendorType, forKey: .vendorType)
    }
    
}


class UserManager: ObservableObject {
    
    static var shared = UserManager()
    @Published var user: User = User()
    private var isUserSignedIn = Auth.auth().currentUser != nil
    
    init() {
        if isUserSignedIn{
            fetchUserFromDB()
            print("--- user role: \(user.role.rawValue)")
        }
        else{
            loadUserFromUD()
        }
    }
    
    func saveUser(user: User) {
        self.user = user
        if isUserSignedIn{
            saveUser2DB(user)
        }
        else{
            saveUser2UD()
        }
    }
    
    func fetchUserFromDB() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/userManager"

            DatabaseManager.shared.fetchUser(path: path, completion: { user in
                DispatchQueue.main.async {
                    self.user = user ?? User()
                    print("Success fetching user")
                }
            })
        }
    }
    
    func saveUser2DB(_ user: User) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/userManager"
            DatabaseManager.shared.saveUser(user, path: path)
        }
    }
    
    // MARK:  user defaults (guest users)
    
    func saveUser2UD() {
        
        // Convert user object to dictionary representation
        let userDict: [String: Any] = [
            "uid": user.uid,
            "role": user.role.rawValue //,
//            "vendorType": user.vendorType?.rawValue ?? ""
        ]
        
        // Save the dictionary to UserDefaults
        UserDefaults.standard.set(userDict, forKey: "user")
        
        print("User saved to UserDefaults")
    }

    // Load user from UserDefaults
    func loadUserFromUD() {
        
        // Retrieve the user dictionary from UserDefaults
        if let userDict = UserDefaults.standard.dictionary(forKey: "user") {
            // Initialize user object from dictionary
            if let user = User(dictionary: userDict) {
                self.user = user
                print("User loaded from UserDefaults")
            }
        }
    }
    
}

