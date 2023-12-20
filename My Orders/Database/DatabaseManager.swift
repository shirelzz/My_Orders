//
//  DatabaseManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 19/12/2023.
//

import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift
//
import Firebase
import Combine
//
//class DatabaseManager {
//    
//    static let shared = DatabaseManager()
//    private let databaseRef = Database.database().reference()
//    
//    private func ordersRef() -> DatabaseReference {
//            return databaseRef.child("orders")
//        }
//    
//    private init() {}
//    
//    // MARK: - Orders
//    
//    func saveOrder(_ order: Order) {
//        let orderRef = databaseRef.child("orders").child(order.orderID)
//        let orderDict = order.dictionaryRepresentation()
//        orderRef.setValue(orderDict)
//    }
//
//    
////    func fetchOrders(completion: @escaping ([Order]) -> Void) {
////        let ordersRef = databaseRef.child("orders")
////        
////        ordersRef.observeSingleEvent(of: .value) { snapshot in
////            guard let orderDicts = snapshot.value as? [String: [String: Any]] else {
////                completion([])
////                return
////            }
////            
////            let orders = orderDicts.compactMap { Order(dictionary: $0.value, orderID: $0.key) }
////            completion(orders)
////        }
////    }
//    
////    func fetchOrders(completion: @escaping ([Order]) -> Void) {
////        let ordersRef = databaseRef.child("orders")
////        
////        ordersRef.observeSingleEvent(of: .value) { snapshot, error in
////            guard error == nil, let orderDicts = snapshot.value as? [String: [String: Any]] else {
////                completion([])
////                return
////            }
////            
////            let orders = orderDicts.compactMap { Order(dictionary: $0.value, orderID: $0.key) }
////            completion(orders)
////        }
////    }
//    
////    func fetchOrders(completion: @escaping ([Order]) -> Void) {
////        let ordersRef = databaseRef.child("orders")
////        
////        ordersRef.observeSingleEvent(of: .value) { snapshot in
////            guard let orderDicts = snapshot.value as? [String: [String: Any]] else {
////                completion([])
////                return
////            }
////            
////            let orders = orderDicts.compactMap { Order(dictionary: $0.value, orderID: $0.key) }
////            completion(orders)
////        }
////    }
//
////    func fetchOrders(completion: @escaping ([Order]) -> Void) {
////        let ordersRef = databaseRef.child("orders")
////        
////        ordersRef.observeSingleEvent(of: .value) { snapshot, error in
////            guard error == nil, let orderDicts = snapshot.value as? [String: [String: Any]] else {
////                completion([])
////                return
////            }
////            
////            let orders = orderDicts.compactMap { Order(dictionary: $0.value, orderID: $0.key) }
////            completion(orders)
////        }
////    }
//
////    func fetchOrders(completion: @escaping ([Order]) -> Void) {
////        let ordersRef = databaseRef.child("orders")
////        
////        ordersRef.observeSingleEvent(of: .value) { snapshot in
////            guard let orderDicts = snapshot.value as? [String: [String: Any]] else {
////                completion([])
////                return
////            }
////            
////            let orders = orderDicts.compactMap { Order(dictionary: $0.value, orderID: $0.key) }
////            completion(orders)
////        }
////    }
//    
//    func fetchOrders(completion: @escaping ([Order]) -> Void) {
//        let ordersRef = databaseRef.child("orders")
//        
//        ordersRef.observeSingleEvent(of: .value) { snapshot in
//            guard let orderDicts = snapshot.value as? [String: [String: Any]] else {
//                completion([])
//                return
//            }
//            
//            let orders = orderDicts.compactMap { Order(dictionary: $0.value, orderID: $0.key) }
//            completion(orders)
//        }
//    }
//    
//    func fetchOrders_bard(completion: @escaping ([Order]) -> Void) {
//            ordersRef().observeSingleEvent(of: .value) { snapshot in
//                guard let orderData = snapshot.value as? [[String: Any]] else {
//                    completion([])
//                    return
//                }
//
//                let orders = orderData.compactMap { Order(dictionary: $0) }
//                completion(orders)
//            }
//        }
//
//
//    
//    func deleteOrder(orderID: String) {
//        let orderRef = databaseRef.child("orders").child(orderID)
//        orderRef.removeValue()
//    }
//    
//    // MARK: - Receipts
//    
//    func saveReceipt(_ receipt: Receipt) {
//        let receiptRef = databaseRef.child("receipts").child(receipt.orderID)
//        receiptRef.setValue(receipt.dictionaryRepresentation)
//    }
//    
////    func fetchReceipts(path: String, completion: @escaping ([Receipt]) -> Void) {
////        let receiptsRef = databaseRef.child("receipts")
////        
////        receiptsRef.child(path).observeSingleEvent(of: .value) { (snapshot)  in
////            guard let receiptDicts = snapshot.value as? [String: [String: Any]] else {
////                completion([])
////                return
////            }
////            
////            let receipts = receiptDicts.compactMap { Receipt(dictionary: $0.value, orderID: $0.key) }
////            completion(receipts)
////        }
////    }
//    
//    func fetchReceipts(path: String, completion: @escaping (Set<Receipt>) -> Void) {
//        let receiptsRef = databaseRef.child("receipts").child(path)
//
//        receiptsRef.observeSingleEvent(of: .value) { snapshot in
//            guard snapshot.exists() else {
//                print("No receipt by path \(path)")
//                completion([])
//                return
//            }
//
//            if let receiptDicts = snapshot.value as? [String: [String: Any]] {
//                let receipts = receiptDicts.compactMap { (key, value) in
//                    var mutableValue = value
//                    mutableValue["receiptMyID"] = key
//                    return Receipt(dictionary: mutableValue)
//                }
//                completion(Set(receipts))
//            } else {
//                print("Invalid data format for receipts")
//                completion([])
//            }
//        }
//    }
//
//    func fetchReceipts(path: String, completion: @escaping (Set<Receipt>) -> Void) {
//        let receiptsRef = databaseRef.child("receipts").child(path)
//
//        receiptsRef.observeSingleEvent(of: .value) { snapshot in
//            guard snapshot.exists() else {
//                print("No receipt by path \(path)")
//                completion([])
//                return
//            }
//
//            if let receiptDicts = snapshot.value as? [String: [String: Any]] {
//                let receipts = receiptDicts.compactMap { (key, value) in
//                    var mutableValue = value
//                    mutableValue["receiptMyID"] = key
//                    return Receipt(dictionary: mutableValue)
//                }
//                completion(Set(receipts))
//            } else {
//                print("Invalid data format for receipts")
//                completion([])
//            }
//        }
//    }
//
//
//    
//    func fetchReceipts_(path: String, completion: @escaping (Set<Receipt>) -> Void) {
//        let receiptsRef = databaseRef.child("receipts")
////        var receiptDicts: [String : [String : Any]]?
////        var unwrappedSnapshot: [String : Any]?
//
//        receiptsRef.child(path).observeSingleEvent(of: .value, with: { snapshot in
//            if snapshot.exists() {
//                let receiptDicts = snapshot.value as? [String: [String: Any]]
//                
//                let receipts = snapshot.children.allObjects as! [Receipt]
////                for snap in receipts {
////                    let receipt = snap.childSnapshot(forPath: "receiptMyID").value as? String ?? ""
//                completion(Set(receipts))
//
//
//                
//            } else {
//                completion([])
//                print("No receipt by path \(path)")
//                return
//            }
//        }
//        )
//        
//    }
//    
//    func fetchReceipts(path: String, completion: @escaping (Set<Receipt>) -> Void) {
//        let receiptsRef = databaseRef.child("receipts").child(path)
//
//        receiptsRef.observeSingleEvent(of: .value) { (snapshot)  in
//            guard let snapshotData = snapshot.value as? [String: [String: Any]] else {
//                print("Invalid data format for receipts")
//                completion([])
//                return
//            }
//
//            let receipts = snapshotData.values.compactMap { value in
//                return Receipt(dictionary: value)
//            }
//
//            completion(Set(receipts))
//        }
//    }
//
//
//
//    
//    func fetchReceipts(path: String, completion: @escaping (Set<Receipt>) -> Void) {
//        let receiptsRef = databaseRef.child("receipts")
//
//        receiptsRef.child(path).observeSingleEvent(of: .value) { (snapshot) in
//            guard let receiptDicts = snapshot.value as? [String: [String: Any]],
//                  let unwrappedSnapshot = snapshot.value as? [String: Any] else {
//                completion([])
//                return
//            }
//
//            let receipts = receiptDicts.compactMap { (_, value) in
//                return Receipt(dictionary: value)
//            }
//
//            completion(Set(receipts))
//        }
//    }
//
//
//
//
//
//    
//    func deleteReceipt(orderID: String) {
//        let receiptRef = databaseRef.child("receipts").child(orderID)
//        receiptRef.removeValue()
//    }
//    
//    // MARK: - Items
//    
//    func saveItem(_ item: InventoryItem) {
//        let itemRef = databaseRef.child("items").child(item.itemID)
//        itemRef.setValue(item.dictionaryRepresentation)
//    }
//    
//    func fetchItems(completion: @escaping ([InventoryItem]) -> Void) {
//        let itemRef = databaseRef.child("items")
//        
//        itemRef.observeSingleEvent(of: .value) { snapshot in
//            guard let itemDicts = snapshot.value as? [String: [String: Any]] else {
//                completion([])
//                return
//            }
//            
//            let items = itemDicts.compactMap { InventoryItem(dictionary: $0.value, id: $0.key) }
//            completion(items)
//        }
//    }
//    
//    func deleteItem(id: String) {
//        let itemRef = databaseRef.child("items").child(id)
//        itemRef.removeValue()
//    }

//}


//class DatabaseManager {
//    static let shared = DatabaseManager()
//    private let database = Database.database().reference()
//
//    // MARK: - Orders
//
//    func saveOrder(_ order: Order) {
//        // Implement how to save an order in the database
//        // For example:
//        let orderRef = database.child("orders").child(order.orderID)
//        orderRef.setValue(order.toJSON())
//    }
//
//    func getAllOrders(completion: @escaping ([Order]) -> Void) {
//        // Implement how to retrieve all orders from the database
//        // For example:
//        let ordersRef = database.child("orders")
//        ordersRef.observeSingleEvent(of: .value) { snapshot in
//            guard let ordersData = snapshot.value as? [String: Any] else {
//                completion([])
//                return
//            }
//
//            let orders = ordersData.compactMap { (_, orderData) -> Order? in
//                guard let orderJSON = orderData as? [String: Any],
//                      let order = Order(json: orderJSON) else {
//                    return nil
//                }
//                return order
//            }
//
//            completion(orders)
//        }
//    }
//
//    // Implement similar functions for items and receipts...
//
//    // MARK: - Helper Functions
//
//    private init() {}
//
//    // Add any helper functions as needed
//}


class DatabaseManager {

    static var shared = DatabaseManager()

    private let databaseRef = Database.database().reference()

    private func ordersRef() -> DatabaseReference {
        return databaseRef.child("orders")
    }

    private func itemsRef() -> DatabaseReference {
        return databaseRef.child("items")
    }

    private func receiptsRef() -> DatabaseReference {
        return databaseRef.child("receipts")
    }

    // MARK: - Reading data
    
    func fetchOrders_gpt(path: String, completion: @escaping ([Order]) -> Void) {
        
        ordersRef().observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else {
                return
            }
            
            var orders = [Order]()
            for (key, orderData) in value {
                guard let orderDict = orderData as? [String: Any],
                      let orderID = orderDict["orderID"] as? String,
                      let customerDict = orderDict["customer"] as? [String: Any],
                      let dessertsArray = orderDict["desserts"] as? [[String: Any]],
                      let orderDateTimestamp = orderDict["orderDate"] as? Double,
                      let deliveryDict = orderDict["delivery"] as? [String: Any],
                      let notes = orderDict["notes"] as? String,
                      let allergies = orderDict["allergies"] as? String,
                      let isDelivered = orderDict["isDelivered"] as? Bool,
                      let isPaid = orderDict["isPaid"] as? Bool
                else {
                    continue
                }

                let customer = Customer(name: customerDict["name"] as? String ?? "", phoneNumber: customerDict["phoneNumber"] as? String ?? "")
                
                var desserts = [OrderItem]()
                for dessertData in dessertsArray {
                    guard let inventoryItemDict = dessertData["inventoryItem"] as? [String: Any],
                          let inventoryItem = InventoryItem(dictionary: inventoryItemDict),
                          let quantity = dessertData["quantity"] as? Int,
                          let price = dessertData["price"] as? Double
                    else {
                        continue
                    }
                    let orderItem = OrderItem(inventoryItem: inventoryItem, quantity: quantity, price: price)
                    desserts.append(orderItem)
                }

                let orderDate = Date(timeIntervalSince1970: orderDateTimestamp)
                
                let delivery = Delivery(
                    address: deliveryDict["address"] as? String ?? "",
                    cost: deliveryDict["cost"] as? Double ?? 0.0
                )
                
                let order = Order(
                    orderID: orderID,
                    customer: customer,
                    desserts: desserts,
                    orderDate: orderDate,
                    delivery: delivery,
                    notes: notes,
                    allergies: allergies,
                    isDelivered: isDelivered,
                    isPaid: isPaid
                )
                
                orders.append(order)
            }
            
            completion(orders)
        })
    }
    
    func fetchItems(completion: @escaping ([InventoryItem]) -> Void) {
        itemsRef().observeSingleEvent(of: .value) { snapshot in
            guard let itemDicts = snapshot.value as? [String: [String: Any]] else {
                completion([])
                return
            }

            let items = itemDicts.compactMap { (_, value) in
                return InventoryItem(dictionary: value)
            }
            completion(items)
        }
    }
    
    func fetchItems_gpt(path: String, completion: @escaping ([InventoryItem]) -> Void) {
        
        itemsRef().observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else {
                return
            }
            
            var items = [InventoryItem]()
            for (key, itemData) in value {
                guard let itemDict = itemData as? [String: Any],
                      let itemID = itemDict["itemID"] as? String,
                      let name = itemDict["name"] as? String,
                      let itemPrice = itemDict["itemPrice"] as? Double,
                      let itemQuantity = itemDict["itemQuantity"] as? Int,
                      let size = itemDict["size"] as? String,
                      let AdditionDateTimestamp = itemDict["AdditionDate"] as? Double,
                      let itemNotes = itemDict["itemNotes"] as? String

                else {
                    continue
                }

                let AdditionDate = Date(timeIntervalSince1970: AdditionDateTimestamp)
                
                let item = InventoryItem(
                     itemID: itemID,
                     name: name,
                     itemPrice: itemPrice,
                     itemQuantity: itemQuantity,
                     size: size,
                     AdditionDate: AdditionDate,
                     itemNotes: itemNotes
                )
                
                items.append(item)
            }
            
            completion(items)
        })
    }
    
    
    
    func fetchReceipts_gpt(path: String, completion: @escaping (Set<Receipt>) -> Void) {
        
        receiptsRef().observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else {
                return
            }
            
            var receipts = [Receipt]()
            for (key, receiptData) in value {
                guard let receiptDict = receiptData as? [String: Any],
                      let myID = receiptDict["myID"] as? Int,
                      let orderID = receiptDict["orderID"] as? String,
                      let pdfData = receiptDict["pdfData"] as? Data,
                      let dateGeneratedTimestamp = receiptDict["dateGenerated"] as? Double,
                      let paymentMethod = receiptDict["paymentMethod"] as? String,
                      let paymentDateTimestamp = receiptDict["paymentDate"] as? Double

                else {
                    continue
                }

                let dateGenerated = Date(timeIntervalSince1970: dateGeneratedTimestamp)
                let paymentDate = Date(timeIntervalSince1970: paymentDateTimestamp)
                
                let receipt = Receipt(
                    myID: myID,
                    orderID: orderID,
                    pdfData: pdfData,
                    dateGenerated: dateGenerated,
                    paymentMethod: paymentMethod,
                    paymentDate: paymentDate
                )
                
                receipts.append(receipt)
            }
            
            completion(Set(receipts))
        })
    }




    // MARK: - Writing data
    
    // bard
//    func saveOrder(order: Order) {
//        let orderData = order.dictionaryRepresentation()
//        ordersRef().child(order.orderID).setValue(orderData)
//    }
//
//    func saveItem(item: InventoryItem) {
//        let itemData = item.dictionaryRepresentation()
//        itemsRef().child(item.itemID).setValue(itemData)
//    }
//
//    func saveReceipt(receipt: Receipt) {
//        let receiptData = receipt.dictionaryRepresentation()
//        receiptsRef().child(receipt.id).setValue(receiptData)
//    }
    
    // gpt
    func saveOrder(_ order: Order, path: String) {
        let orderRef = databaseRef.child("orders").child(path).child(order.orderID)
        orderRef.setValue(order.dictionaryRepresentation())
    }
    
    func saveItem(_ item: InventoryItem, path: String) {
        let itemRef = databaseRef.child("items").child(path).child(item.id)
        itemRef.setValue(item.dictionaryRepresentation())
        
    }
    
    func saveReceipt(_ receipt: Receipt, path: String) {
        let receiptRef = databaseRef.child("receipts").child(path).child(receipt.orderID)
        receiptRef.setValue(receipt.dictionaryRepresentation())
    }

    // MARK: - Deleting data

    
    func deleteOrder(orderID: String, path: String) {
        let orderRef = databaseRef.child("orders").child(path).child(orderID)
        orderRef.removeValue()
    }

    func deleteItem(itemID: String, path: String) {
        let itemRef = databaseRef.child("items").child(path).child(itemID)
        itemRef.removeValue()
    }

    func deleteReceipt(orderID: String, path: String) {
        let receiptRef = databaseRef.child("receipts").child(path).child(orderID)
        receiptRef.removeValue()
    }
//    func deleteOrder(orderID: String) {
//        ordersRef().child(orderID).removeValue()
//    }
//
//    func deleteItem(itemID: String) {
//        itemsRef().child(itemID).removeValue()
//    }
//
//    func deleteReceipt(receiptID: String) {
//        receiptsRef().child(receiptID).removeValue()
//    }
    
    // MARK: - Updating data

    func updateOrderInDB(_ order: Order, path: String, completion: @escaping (Bool) -> Void) {
        let orderRef = databaseRef.child("orders").child(path).child(order.orderID)
        orderRef.updateChildValues(order.dictionaryRepresentation()) { error, _ in
            completion(error == nil)
        }
    }
    
    func updateItemInDB(_ item: InventoryItem, path: String, completion: @escaping (Bool) -> Void) {
        let itemRef = databaseRef.child("items").child(path).child(item.itemID)
        itemRef.updateChildValues(item.dictionaryRepresentation()) { error, _ in
            completion(error == nil)
        }
    }
    
//    func saveGeneratedReceiptIDs(_ generatedReceiptIDs: Set<String>, path: String) {
//            let generatedReceiptIDsRef = databaseRef.child("generatedReceiptIDs").child(path)
//            generatedReceiptIDsRef.setValue(Array(generatedReceiptIDs))
//        }
//
//        func fetchGeneratedReceiptIDs(path: String, completion: @escaping (Set<String>) -> Void) {
//            let generatedReceiptIDsRef = databaseRef.child("generatedReceiptIDs").child(path)
//
//            generatedReceiptIDsRef.observeSingleEvent(of: .value) { snapshot in
//                guard let value = snapshot.value as? [String] else {
//                    completion([])
//                    return
//                }
//
//                let setOfGeneratedReceiptIDs = Set(value)
//                completion(setOfGeneratedReceiptIDs)
//            }
//        }
//
//        func deleteGeneratedReceiptIDs(path: String) {
//            let generatedReceiptIDsRef = databaseRef.child("generatedReceiptIDs").child(path)
//            generatedReceiptIDsRef.removeValue()
//        }

}

