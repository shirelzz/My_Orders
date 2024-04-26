//
//  ShoppingList.swift
//  My Orders
//
//  Created by שיראל זכריה on 12/01/2024.
//

import Foundation
import FirebaseAuth

struct ShoppingItem: Codable, Identifiable, Hashable {
    
    var id: String { shoppingItemID }
    var shoppingItemID: String
//    let id = UUID()
    var name: String
    var quantity: Double
    var isChecked: Bool
    
    init() {
        self.shoppingItemID = ""
        self.name = ""
        self.quantity = 0
        self.isChecked = false
        
    }
    
    init(shoppingItemID: String, name: String, quantity: Double, isChecked: Bool) {
        self.shoppingItemID = shoppingItemID
        self.name = name
        self.quantity = quantity
        self.isChecked = isChecked
    }
    
    func dictionaryRepresentation() -> [String: Any] {

        let ShoppingItemDict: [String: Any] = [
            
            "shoppingItemID": shoppingItemID,
            "name": name,
            "quantity": quantity,
            "isChecked": isChecked

        ]
        return ShoppingItemDict
    }
    
    init?(dictionary: [String: Any]) {
        
        guard let shoppingItemID = dictionary["shoppingItemID"] as? String,
              let name = dictionary["name"] as? String,
              let quantity = dictionary["quantity"] as? Double,
              let isChecked = dictionary["isChecked"] as? Bool
        else {
            return nil
        }
        self.shoppingItemID = shoppingItemID
        self.name = name
        self.quantity = quantity
        self.isChecked = isChecked

    }
}

class ShoppingList: ObservableObject {
    
    static var shared = ShoppingList()
    @Published var shoppingItems: [ShoppingItem] = []
    private var isUserSignedIn = Auth.auth().currentUser != nil

    init() {
        if isUserSignedIn{
            fetchShoppingItems()
        }
        else {
            loadShoppingItemsFromUD()
        }
    }
    
    func fetchShoppingItems() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            print("Current UserID: \(userID)")
            let path = "users/\(userID)/shoppingList"

            ShoppingDatabaseManager.shared.fetchShoppingItems(path: path, completion: { fetchedShoppingItems in

                DispatchQueue.main.async {
                    self.shoppingItems = fetchedShoppingItems
                    print("Success fetching shoppingItems")
                }


            })
        }
    }
    
    func saveItem2DB(_ item: ShoppingItem) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/shoppingList"
            ShoppingDatabaseManager.shared.saveItem(item, path: path)
        }
    }
    
    func deleteItemFromDB(itemID: String) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/shoppingList"
            ShoppingDatabaseManager.shared.deleteItem(itemID: itemID, path: path)
        }
    }
    
    func addItem(item: ShoppingItem) {
        shoppingItems.append(item)
        if isUserSignedIn{
            saveItem2DB(item)
        }
        else{
            saveItems2UD()
        }
    }
    
    private func saveItems2UD() {
        if let encodedData = try? JSONEncoder().encode(Array(shoppingItems)) {
            UserDefaults.standard.set(encodedData, forKey: "shoppingItems")
            print("success decoding shopping items! save")
        }
        else{
            print("Error decoding shopping items save")
        }
    }
    
    // load items from UserDefaults
    func loadShoppingItemsFromUD() {
        if let savedData = UserDefaults.standard.data(forKey: "shoppingItems"),
           let decodedItems = try? JSONDecoder().decode([ShoppingItem].self, from: savedData) {
            shoppingItems = decodedItems
            print("success decoding shoppingItems! load")
        }
        else{
            print("Error decoding shoppingItems load")
        }
    }
    
    func deleteItem(item: ShoppingItem) {
        if let index = shoppingItems.firstIndex(where: { $0.id == item.id}) {
            print("--->Deleting item: \(item.name)")

            shoppingItems.remove(at: index)
            if isUserSignedIn{
                deleteItemFromDB(itemID: item.shoppingItemID)
            }
            else{
                saveItems2UD()
            }
        }
    }
    
    private func updateItem(index: Array<ShoppingItem>.Index) {

        if isUserSignedIn {
            if let currentUser = Auth.auth().currentUser {
                let userID = currentUser.uid
                let path = "users/\(userID)/shoppingList/\(shoppingItems[index].shoppingItemID)"
                ShoppingDatabaseManager.shared.updateItemInDB(shoppingItems[index], path: path) { success in
                    if !success {
                        print("updating in the database failed (update shopping item)")
                    }
                }
            }
        } else {
            saveItems2UD()
        }
    }
    
    func updateIsChecked(item: ShoppingItem, newState: Bool) {
        if let index = shoppingItems.firstIndex(where: { $0.id == item.id }) {

//        if let index = shoppingItems.firstIndex(of: item) {
            shoppingItems[index].isChecked = newState
            print("--- 2 shoppingItems[index] ischecked: \(shoppingItems[index].isChecked.description)")
            updateItem(index: index)
            
        }
        print("--- 2")

    }
    
    func toggleCheck(item: ShoppingItem) {
           var isChecked = false
           if let index = shoppingItems.firstIndex(where: { $0.id == item.id }) {
               shoppingItems[index].isChecked.toggle()
               isChecked = shoppingItems[index].isChecked
               
   //            if item.isHearted {
   //                if let index = favShoppingItems.firstIndex(where: { $0.id == item.id }) {
   //                    favShoppingItems[index].isChecked.toggle()
   //                }
   //            }
               
               updateIsChecked(item: item, newState: isChecked)
               
               print("--- 0 ischecked: \(isChecked)")
               print("--- 0 item ischecked: \(item.isChecked.description)")
               print("--- 0 shoppingItems[index] ischecked: \(shoppingItems[index].isChecked.description)")
               
               if isChecked {
                   // Delay the deletion after 4 seconds
                       DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                           guard let self = self else { return }

                           // Check if the item is still checked before deleting
                           if shoppingItems[index].isChecked {
                               self.deleteItem(item: item)
                           }
                       }
               }

           }

       }
    
    func updateQuantity(item: ShoppingItem, newQuantity: Double) {
           if let index = shoppingItems.firstIndex(of: item) {
               shoppingItems[index].quantity = newQuantity
               
               updateItem(index: index)
           }
       }
    
    func getSortedItemsByName() -> [ShoppingItem] {
          return shoppingItems.sorted(by: { $0.name < $1.name })
      }
}

