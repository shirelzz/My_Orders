//
//  Customer.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/01/2024.
//

import Foundation

struct CustomerUser: Codable {
    
    var id: String
    var following: [String]
    
}

class CustomerManager: ObservableObject {
    static let shared = CustomerManager()
    @Published var following: [String] = []
}

struct Business: Codable {
    
    var id: String
    var name: String
    var items: [InventoryItem]
    
    init() {
        self.id = ""
        self.name = ""
        self.items = []
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
