//
//  ShoppingDatabaseManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/04/2024.
//

import Foundation

class ShoppingDatabaseManager: DatabaseManager {
    
    static var shared = ShoppingDatabaseManager()
    
    // MARK: - Reading data
    
    func fetchShoppingItems(path: String, completion: @escaping ([ShoppingItem]) -> ()) {
      
        let shoppingItemsRef = databaseRef.child(path)
        
        shoppingItemsRef.observeSingleEvent(of: .value, with: { (snapshot) in
        guard let value = snapshot.value as? [String: Any] else {
                print("No shoppingItems data found")
                completion([])
                return
            }
            
            var shoppingItems = [ShoppingItem]()
            for (_, itemData) in value {
                guard let shoppingItemDict = itemData as? [String: Any],
                      let shoppingItemID = shoppingItemDict["shoppingItemID"] as? String,
                      let name = shoppingItemDict["name"] as? String,
                      let quantity = shoppingItemDict["quantity"] as? Double,
                      let isChecked = shoppingItemDict["isChecked"] as? Bool
 
                else {
                    print("shoppingItem else called")
                    continue
                }
                
                let shoppingItem = ShoppingItem(
                    shoppingItemID: shoppingItemID,
                    name:  name,
                    quantity: quantity,
                    isChecked: isChecked
                )
                
                shoppingItems.append(shoppingItem)
            }
            completion(shoppingItems)
        })
    }
    
    // MARK: - Writing data
    
    func saveItem(_ item: ShoppingItem, path: String) {
        let itemRef = databaseRef.child(path).child(item.id)
        itemRef.setValue(item.dictionaryRepresentation())
    }
    
    // MARK: - Updating data
    
    func updateItemInDB(_ item: ShoppingItem, path: String, completion: @escaping (Bool) -> Void) {
        let itemRef = databaseRef.child(path)
        itemRef.updateChildValues(item.dictionaryRepresentation()) { error, _ in
            completion(error == nil)
        }
    }
    
}
