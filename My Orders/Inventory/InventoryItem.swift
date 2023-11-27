//
//  InventoryItem.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import Foundation

struct InventoryItem: Codable, Identifiable, Hashable{
    
    var id = UUID()
    var name: String
    var itemPrice: Int
    var itemQuantity: Int
    var itemNotes: String
    var catalogNumber: String
    


}

class InventoryManager: ObservableObject {
    
    static var shared = InventoryManager()
    @Published var items: Set<InventoryItem> = []
    
    func addItem(item: InventoryItem) {
        items.insert(item)
        saveItems()
    }
    
    func editItem(item: InventoryItem, newName: String, newPrice: Int, newQuantity: Int, newNotes: String) {
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
  

//    init(catalogNumber: String, name: String, price: Double) {
//        self.catalogNumber = catalogNumber
//        self.name = name
//        self.price = price
//    }
}
