//
//  InventoryItem.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import Foundation
import UserNotifications
import FirebaseAuth

struct InventoryItem: Codable, Identifiable, Hashable{ //
    
    var id: String { itemID }
    var itemID: String
    var name: String
    var itemPrice: Double
    var itemQuantity: Int
    var size: String
    var AdditionDate: Date
    var itemNotes: String
    
    init(itemID: String, name: String, itemPrice: Double, itemQuantity: Int, size: String, AdditionDate: Date, itemNotes: String) {
        self.itemID = itemID
        self.name = name
        self.itemPrice = itemPrice
        self.itemQuantity = itemQuantity
        self.size = size
        self.AdditionDate = AdditionDate
        self.itemNotes = itemNotes
    }
    
    init?(dictionary: [String: Any]) {
        guard let itemID = dictionary["itemID"] as? String,
              let name = dictionary["name"] as? String,
              let price = dictionary["itemPrice"] as? Double,
              let quantity = dictionary["itemQuantity"] as? Int,
              let size = dictionary["size"] as? String,
              let additionDate = dictionary["AdditionDate"] as? Date,
              let notes = dictionary["itemNotes"] as? String
        else {
            return nil
        }
        self.itemID = itemID
        self.name = name
        self.itemPrice = price
        self.itemQuantity = quantity
        self.size = size
        self.AdditionDate = additionDate
        self.itemNotes = notes
        
    }
}

extension InventoryItem {
    
    func dictionaryRepresentation() -> [String: Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        var itemDict: [String: Any] = [
            
            "itemID": itemID,
            "name": name,
            "itemPrice": itemPrice,
            "itemQuantity": itemQuantity,
            "size": size,
            "AdditionDate": dateFormatter.string(from: AdditionDate),
            "itemNotes": itemNotes,

        ]
        return itemDict
    }
}

class InventoryManager: ObservableObject {
    
    static var shared = InventoryManager()
    @Published var items: [InventoryItem] = []
    private var isUserSignedIn = Auth.auth().currentUser != nil
    
    init() {
        if isUserSignedIn{
            fetchItemsFromDB()
        }
        else{
            loadItemsFromUD()
        }
    }
    
    // MARK: - Firebase Realtime Database (signed in users)
    
    func fetchItemsFromDB() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/items"
            
            DatabaseManager.shared.fetchItems_gpt(path: path, completion: { fetchedItems in
                self.items = fetchedItems
            })
        }
    }
    
        func saveItem2DB(_ item: InventoryItem) {
            if let currentUser = Auth.auth().currentUser {
                let userID = currentUser.uid
                let path = "users/\(userID)/items"
                DatabaseManager.shared.saveItem(item, path: path)
            }
        }
        
        func deleteItemFromDB(itemID: String) {
            if let currentUser = Auth.auth().currentUser {
                let userID = currentUser.uid
                let path = "users/\(userID)/items"
                DatabaseManager.shared.deleteItem(itemID: itemID, path: path)
            }
        }
    
    // MARK:  user defaults (guest users)
    
    private func saveItems2UD() {
        if let encodedData = try? JSONEncoder().encode(Array(items)) {
            UserDefaults.standard.set(encodedData, forKey: "items")
            print("success decoding items! save")
        }
        else{
            print("Error decoding items save")
        }
    }
    

    
    // load items from UserDefaults
    func loadItemsFromUD() {
        if let savedData = UserDefaults.standard.data(forKey: "items"),
           let decodedItems = try? JSONDecoder().decode([InventoryItem].self, from: savedData) {
            items = decodedItems
            print("success decoding items! load")
        }
        else{
            print("Error decoding items load")
        }
    }
    
    // MARK:  - For all users
    
    func addItem(item: InventoryItem) {
        items.append(item)
        if isUserSignedIn{
            saveItem2DB(item)
        }
        else{
            saveItems2UD()
        }
    }
    
    func deleteItem(item: InventoryItem) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
            if isUserSignedIn{
                deleteItemFromDB(itemID: item.itemID)
            }
            else{
                saveItems2UD()
            }
        }
    }
    
    func editItem(item: InventoryItem, newName: String, newPrice: Double, newQuantity: Int, newSize: String, newNotes: String) {
        if let index = items.firstIndex(of: item) {
            var editedItem = item
            editedItem.name = newName
            editedItem.itemPrice = newPrice
            editedItem.itemQuantity = newQuantity
            editedItem.size = newSize
            editedItem.itemNotes = newNotes
            
            items[index] = editedItem
            
            if isUserSignedIn {
                if let currentUser = Auth.auth().currentUser {
                    let userID = currentUser.uid
                    let path = "users/\(userID)/items"
                    
                    DatabaseManager.shared.updateItemInDB(editedItem, path: path) { success in
                        if !success {
                            print("updating in the database failed (editItem)")
                        }
                    }
                }
            } else {
                saveItems2UD()
            }
        }
    }
    
    func updateQuantity(item: InventoryItem, newQuantity: Int) {
        if let index = items.firstIndex(of: item) {
            items[index].itemQuantity = newQuantity
            
            if isUserSignedIn {
                if let currentUser = Auth.auth().currentUser {
                    let userID = currentUser.uid
                    let path = "users/\(userID)/items"
                    
                    DatabaseManager.shared.updateItemInDB(items[index], path: path) { success in
                        if !success {
                            print("updating in the database failed (editItem)")
                        }
                    }
                }
            } else {
                saveItems2UD()
            }
        }
    }
    
    func getItems() -> [InventoryItem] {
        return items
    }
    
    
    // MARK: - Notifications

    func scheduleInventoryNotification(item: InventoryItem, notifyWhenQuantityReaches: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Inventory Alert"
        content.body = "\(item.name) is running low. Current quantity: \(item.itemQuantity)"
        
        let triggerQuantity = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)  // Set to 1 second for testing purposes, adjust as needed
        
        let request = UNNotificationRequest(identifier: item.itemID, content: content, trigger: triggerQuantity)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling inventory notification: \(error.localizedDescription)")
            }
        }
    }
}
