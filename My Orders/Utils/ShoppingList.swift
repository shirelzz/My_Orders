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
    var quantity: Int
    var isChecked: Bool
    
    init(shoppingItemID: String, name: String, quantity: Int, isChecked: Bool) {
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
              let quantity = dictionary["quantity"] as? Int,
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
    var timer: Timer?

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

            DatabaseManager.shared.fetchShoppingItems(path: path, completion: { fetchedShoppingItems in

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
            DatabaseManager.shared.saveItem(item, path: path)
        }
    }
    
    func deleteItemFromDB(itemID: String) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/shoppingList"
            DatabaseManager.shared.deleteItem(itemID: itemID, path: path)
        }
    }

    // Example function to add a new item to the shopping list
//    func addItem(name: String, quantity: Int) {
//        let newItem = ShoppingItem(shoppingItemID: UUID().uuidString, name: name, quantity: quantity, isChecked: false)
//        shoppingItems.append(newItem)
//    }
    
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
    
    func toggleCheck(item: ShoppingItem) {
        if let index = shoppingItems.firstIndex(where: { $0.id == item.id }) {
            shoppingItems[index].isChecked.toggle()
            print("--->Item checked: \(shoppingItems[index].isChecked)")
            updateIsChecked(item: item, newState: shoppingItems[index].isChecked)
        }
        
        if item.isChecked {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
                self?.deleteItem(item: item)
            }
            print("--->Timer started")
        }
        
    }

    
    func deleteItem(item: ShoppingItem) {
//        if let index = shoppingItems.firstIndex(of: item) {
        if let index = shoppingItems.firstIndex(where: { $0.id == item.id && $0.isChecked }) {
            print("--->Deleting item: \(item.name)")

            shoppingItems.remove(at: index)
            if isUserSignedIn{
                deleteItemFromDB(itemID: item.shoppingItemID)
            }
            else{
                saveItems2UD()
            }
            
            // If the item is removed, cancel the timer
            timer?.invalidate()
        }
    }
    
    func updateIsChecked(item: ShoppingItem, newState: Bool) {
        if let index = shoppingItems.firstIndex(of: item) {
            shoppingItems[index].isChecked = newState
            
            if isUserSignedIn {
                if let currentUser = Auth.auth().currentUser {
                    let userID = currentUser.uid
                    let path = "users/\(userID)/shppingList/\(shoppingItems[index].shoppingItemID)"
                    
                    DatabaseManager.shared.updateItemInDB(shoppingItems[index], path: path) { success in
                        if !success {
                            print("updating in the database failed (updateIsChecked)")
                        }
                    }
                }
            } else {
                saveItems2UD()
            }
        }
    }
}

