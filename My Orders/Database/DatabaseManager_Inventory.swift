//
//  DatabaseManager_Inventory.swift
//  My Orders
//
//  Created by שיראל זכריה on 02/04/2024.
//

import Foundation

extension DatabaseManager {
    
    func fetchItems(path: String, completion: @escaping ([InventoryItem]) -> ()) {
      
        let itemsRef = databaseRef.child(path)
        
        itemsRef.observeSingleEvent(of: .value, with: { (snapshot) in
        guard let value = snapshot.value as? [String: Any] else {
                print("No items data found")
                completion([])
                return
            }
            
            var items = [InventoryItem]()
            for (_, itemData) in value {
                guard let itemDict = itemData as? [String: Any],
                      let itemID = itemDict["itemID"] as? String,
                      let name = itemDict["name"] as? String,
                      let itemPrice = itemDict["itemPrice"] as? Double,
                      let itemQuantity = itemDict["itemQuantity"] as? Int,
                      let size = itemDict["size"] as? String,
                      let additionDateStr = itemDict["AdditionDate"] as? String,
                      let itemNotes = itemDict["itemNotes"] as? String
                else {
                    print("item else called")
                    continue
                }
                
                let additionDate = self.convertStringToDate(additionDateStr)

                var tags: [String]? = nil
                if let parsedTags = itemDict["tags"] as? [String] {
                    tags = parsedTags
                }
                
                let item = InventoryItem(
                    itemID: itemID,
                    name:  name,
                    itemPrice: itemPrice,
                    itemQuantity: itemQuantity,
                    size: size ,
                    AdditionDate: additionDate,
                    itemNotes:  itemNotes,
                    tags: tags
                )
                
                items.append(item)
            }
            completion(items)
        })
    }
    
    func saveItem(_ item: InventoryItem, path: String) {
        let itemRef = databaseRef.child(path).child(item.id)
        itemRef.setValue(item.dictionaryRepresentation())
    }
    
    func updateItemInDB(_ item: InventoryItem, path: String, completion: @escaping (Bool) -> Void) {
        let itemRef = databaseRef.child(path)
        itemRef.updateChildValues(item.dictionaryRepresentation()) { error, _ in
            completion(error == nil)
        }
    }
    
    func clearOutOfStockItemsFromDB(path: String, completion: @escaping () -> Void) {
        let itemsRef = databaseRef.child(path)
        
        itemsRef.observeSingleEvent(of: .value) { snapshot in
            guard var items = snapshot.value as? [String: [String: Any]] else {
                print("error clearing items")
                completion()
                return
            }
            
            // Remove out-of-stock items
            items = items.filter { (_, itemData) in
                guard let quantity = itemData["itemQuantity"] as? Int else {
                    return true // Keep if quantity information is not available
                }
                return quantity > 0
            }
            
            // Save the updated items back to the database
            itemsRef.setValue(items) { error, _ in
                if let error = error {
                    print("Error clearing out-of-stock items: \(error.localizedDescription)")
                } else {
                    print("Out-of-stock items cleared successfully from database.")
                }
                completion()
            }
        }
    }
}
