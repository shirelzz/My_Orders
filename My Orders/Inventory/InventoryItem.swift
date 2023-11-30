//
//  InventoryItem.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import Foundation
import UserNotifications

struct InventoryItem: Codable, Identifiable, Hashable{ //
    
    var id = UUID()
    var name: String
    var itemPrice: Double
    var itemQuantity: Int
    var itemNotes: String
    var catalogNumber: String
    
//    func hash(into hasher: inout Hasher) {
//            hasher.combine(id)
//        }
//
//        static func == (lhs: InventoryItem, rhs: InventoryItem) -> Bool {
//            return lhs.id == rhs.id
//        }

}

class InventoryManager: ObservableObject {
    
    static var shared = InventoryManager()
    @Published var items: Set<InventoryItem> = Set()
    
    func addItem(item: InventoryItem) {
        items.insert(item)
        saveItems()
    }
    
    func editItem(item: InventoryItem, newName: String, newPrice: Double, newQuantity: Int, newNotes: String) {
        
        if items.firstIndex(of: item) != nil {
                
                items.remove(item)
                var editedItem = item
                editedItem.name = newName
                editedItem.itemPrice = newPrice
                editedItem.itemQuantity = newQuantity
                editedItem.itemNotes = newNotes


                items.insert(editedItem)
                saveItems()
            }
    }
    
//    func editItem(item: InventoryItem, newQuantity: Int) {
//        if items.contains(item) {
//            items.remove(item)
//            var editedItem = item
//            editedItem.itemQuantity = newQuantity
//            items.insert(editedItem)
//            saveItems()
//        }
//    }


    
    func removeItem(item: InventoryItem) {
        items.remove(item)
        saveItems()
    }
    
    func getItems() -> Set<InventoryItem> {
        return items
    }
    
    private func saveItems() {
        if let encodedData = try? JSONEncoder().encode(Array(items)) {
            UserDefaults.standard.set(encodedData, forKey: "items")
        }
    }
    
    // load items from UserDefaults
    func loadItems() {
        if let savedData = UserDefaults.standard.data(forKey: "items"),
           let decodedItems = try? JSONDecoder().decode([InventoryItem].self, from: savedData) {
            items = Set(decodedItems)
        }
    }
    
    init() {
        loadItems()        
    }
    
    func scheduleInventoryNotification(item: InventoryItem, notifyWhenQuantityReaches: Int) {
            let content = UNMutableNotificationContent()
            content.title = "Inventory Alert"
            content.body = "\(item.name) is running low. Current quantity: \(item.itemQuantity)"

            let triggerQuantity = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)  // Set to 1 second for testing purposes, adjust as needed

            let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: triggerQuantity)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling inventory notification: \(error.localizedDescription)")
                }
            }
        }
  

//    init(catalogNumber: String, name: String, price: Double) {
//        self.catalogNumber = catalogNumber
//        self.name = name
//        self.price = price
//    }
}
