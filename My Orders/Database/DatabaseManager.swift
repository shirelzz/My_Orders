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

class DatabaseManager {
    
    static var shared = DatabaseManager()
    
    private var databaseRef = Database.database().reference()
    
    private func usersRef() -> DatabaseReference {
        return databaseRef.child("users")
    }
    
    // MARK: - Reading data
    
    func fetchOrders_gpt1(path: String, completion: @escaping ([Order]) -> ()) {
        let ordersRef = databaseRef.child(path)

        ordersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                print("No orders data found")
                completion([])
                return
            }

            var orders = [Order]()
            for (orderID, orderData) in value {
                guard
                    let allergies = orderData["allergies"] as? String,
                    let customerData = orderData["customer"] as? [String: Any],
                    let deliveryData = orderData["delivery"] as? [String: Any],
                    let isDelivered = orderData["isDelivered"] as? Bool,
                    let isPaid = orderData["isPaid"] as? Bool,
                    let notes = orderData["notes"] as? String,
                    let orderDateStr = orderData["orderDate"] as? String,
                    let orderItemsData = orderData["orderItems"] as? [String: [String: Any]]
                else {
                    continue
                }

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                guard let orderDate = dateFormatter.date(from: orderDateStr) else {
                    continue
                }

                let customer = Customer(
                    name: customerData["name"] as? String ?? "",
                    phoneNumber: customerData["phoneNumber"] as? String ?? ""
                )

                let delivery = Delivery(
                    address: deliveryData["address"] as? String ?? "",
                    cost: deliveryData["cost"] as? Double ?? 0.0
                )

                var orderItems = [OrderItem]()
                for (_, orderItemData) in orderItemsData {
                    guard
                        let inventoryItemData = orderItemData["inventoryItem"] as? [String: Any],
                        let quantity = orderItemData["quantity"] as? Int,
                        let price = orderItemData["price"] as? Double
                    else {
                        continue
                    }

                    let inventoryItem = InventoryItem(
                        itemID: inventoryItemData["itemID"] as? String ?? "",
                        name: inventoryItemData["name"] as? String ?? "",
                        itemPrice: inventoryItemData["itemPrice"] as? Double ?? 0.0,
                        itemQuantity: inventoryItemData["itemQuantity"] as? Int ?? 0,
                        size: inventoryItemData["size"] as? String ?? "",
                        AdditionDate: dateFormatter.date(from: inventoryItemData["AdditionDate"] as? String ?? "") ?? Date(),
                        itemNotes: inventoryItemData["itemNotes"] as? String ?? ""
                    )

                    let orderItem = OrderItem(
                        inventoryItem: inventoryItem,
                        quantity: quantity,
                        price: price
                    )

                    orderItems.append(orderItem)
                }

                let order = Order(
                    orderID: orderID,
                    customer: customer,
                    orderItems: orderItems,
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

    
    func fetchOrders_gpt(path: String, completion: @escaping ([Order]) -> ()) {
        let ordersRef = databaseRef.child(path)

        ordersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print("---> Snapshot: \(snapshot)")

            guard let value = snapshot.value as? [String: Any] else {
                print("No orders data found")
                completion([])
                return
            }

            print("---> before orders:")

            var orders = [Order]()
            for (_, orderData) in value {
                guard let orderDict = orderData as? [String: Any],
                      let orderID = orderDict["orderID"] as? String,
                      let customerDict = orderDict["customer"] as? [String: Any],
//                      let customer = Customer(dictionary: customerData),
                      let orderItemsData = orderDict["orderItems"] as? [[String: Any]],
//                        let orderItemsData = orderDict["orderItems"] as? [String: [String: Any]],

                      let orderDateStr = orderDict["orderDate"] as? String,
//                      let orderDate = dateFormatter.date(from: orderDateStr),
                      let deliveryDict = orderDict["delivery"] as? [String: Any],
//                      let delivery = Delivery(dictionary: deliveryData),
                      let notes = orderDict["notes"] as? String,
                      let allergies = orderDict["allergies"] as? String,
                      let isDelivered = orderDict["isDelivered"] as? Bool,
                      let isPaid = orderDict["isPaid"] as? Bool
                else {
                    print("stopped middle way")
                    continue
                }
                
                print("im here")
                let customer = Customer(name: customerDict["name"] as? String ?? "",
                                        phoneNumber: customerDict["phoneNumber"] as? String ?? "")
                print("im here1 \(customer)")

                let delivery = Delivery(
                    address: deliveryDict["address"] as? String ?? "",
                    cost: deliveryDict["cost"] as? Double ?? 0.0
                )
                print("im here2 \(delivery)")

//  n
                
                let orderDate = self.convertStringToDate(orderDateStr)
                print("im here3 \(orderDate)")

                
                print("---> before order items:")
//                                var orderItems = [OrderItem]()
//                                for orderItemData in orderItemsData {
//                                    guard let orderItem = OrderItem(dictionary: orderItemData)
//                                    else {
//                                        print("---> stopped while creating order items")
//                                        continue
//                                    }
//                                    orderItems.append(orderItem)
//                                }
                // Parse orderItems
//                var orderItems = [OrderItem]()
//                for orderItemData in orderItemsData {
//                    guard
//                        let inventoryItemDict = orderItemData["inventoryItem"] as? [String: Any],
//                        let inventoryItem = InventoryItem(dictionary: inventoryItemDict),
//                        let quantity = orderItemData["quantity"] as? Int,
//                        let price = orderItemData["price"] as? Double
//                    else {
//                        print("Error parsing order item data")
//                        continue
//                    }
//                    
//                    let orderItem = OrderItem(inventoryItem: inventoryItem, quantity: quantity, price: price)
//                    orderItems.append(orderItem)
//                }

                var orderItems = [OrderItem]()
                for orderItemData in orderItemsData {
                         guard let orderItemDict = orderItemData as? [String: Any],
                               let inventoryItemDict = orderItemDict["inventoryItem"] as? [String: Any],
                               
                               let quantity = orderItemDict["quantity"] as? Int,
                               let price = orderItemDict["price"] as? Double,
                               
                                let itemID = inventoryItemDict["itemID"] as? String,
                                let name = inventoryItemDict["name"] as? String,
                                let itemPrice = inventoryItemDict["itemPrice"] as? Double,
                                let itemQuantity = inventoryItemDict["itemQuantity"] as? Int,
                                let size = inventoryItemDict["size"] as? String,
                                let additionDateStr = inventoryItemDict["AdditionDate"] as? String,
                                let itemNotes = inventoryItemDict["itemNotes"] as? String
                         else {
                             print("Failed to parse orderItemData")
                             continue
                         }
                         
                         // Parse inventoryItem
                    print("---> before parse inventoryItem:")

//                         guard let inventoryItem = InventoryItem(dictionary: inventoryItemDict) else {
//                             print("Failed to parse inventoryItem")
//                             continue
//                         }
                  
                    
                    let additionDate = self.convertStringToDate(additionDateStr)

                    let inventoryItem = InventoryItem(
                        itemID: itemID,
                        name:  name,
                        itemPrice: itemPrice,
                        itemQuantity: itemQuantity,
                        size: size ,
                        AdditionDate: additionDate,
                        itemNotes:  itemNotes
                    )

                    let orderItem = OrderItem(
                        inventoryItem: inventoryItem,
                        quantity: quantity,
                        price: price
                    )
                         
//                         let orderItem = OrderItem(inventoryItem: inventoryItem, quantity: quantity, price: price)
                         orderItems.append(orderItem)
                     }
                print("---> order items: \(orderItems)")


                let order = Order(
                    orderID: orderID,
                    customer: customer,
                    orderItems: orderItems,
                    orderDate: orderDate,
                    delivery: delivery,
                    notes: notes,
                    allergies: allergies,
                    isDelivered: isDelivered,
                    isPaid: isPaid
                )
            
                print("---> order appended: \(order)")
                orders.append(order)
            }
            print("---> orders: \(orders)")
            completion(orders)
        })
    }

    



//    func fetchOrders_gpt(path: String, completion: @escaping ([Order]) -> ()) {
//        let ordersRef = databaseRef.child(path)
//        
//        ordersRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let value = snapshot.value as? [String: Any] else {
//                print("No orders data found")
//                completion([])
//                return
//            }
//            
//            var orders = [Order]()
//            
//            for (_, orderData) in value {
//                guard let orderDict = orderData as? [String: Any],
//                      let orderID = orderDict["orderID"] as? String,
//                      let customerDict = orderDict["customer"] as? [String: Any],
////                      let orderItemsArray = orderDict["orderItems"] as? [[String: Any]],
//                      let orderItemsNode = orderDict["orderItems"] as? [String: [String: Any]],
//
//                      let orderDateTimestamp = orderDict["orderDate"] as? String,
//                      let deliveryDict = orderDict["delivery"] as? [String: Any],
//                      let notes = orderDict["notes"] as? String,
//                      let allergies = orderDict["allergies"] as? String,
//                      let isDelivered = orderDict["isDelivered"] as? Bool,
//                      let isPaid = orderDict["isPaid"] as? Bool
//                else {
//                    continue
//                }
//                
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                guard let orderDate = dateFormatter.date(from: orderDateTimestamp) else {
//                    continue
//                }
//                
//                let customer = Customer(name: customerDict["name"] as? String ?? "",
//                                        phoneNumber: customerDict["phoneNumber"] as? String ?? "")
//                
////                var orderItems = [OrderItem]()
////                for (_, orderItemData) in orderItemsNode {
////                    guard let orderItem = OrderItem(dictionary: orderItemData) else {
////                        continue
////                    }
////                    orderItems.append(orderItem)
////                }
//                
//                // Fetch order items
//                var orderItems = [OrderItem]()
//                for orderItemData in orderItemsNode {
//                    guard let orderItem = OrderItem(from: orderItemData) else {
//                          continue
//                    }
//                    orderItems.append(orderItem)
//                }
////                        for orderItemData in orderItemsArray {
////                            if let orderItem = OrderItem(from: orderItemData) {
////                                orderItems.append(orderItem)
////                            }
////                        }
//                
////                for orderItemData in orderItemsNode {
////                    guard let inventoryItemDict = orderItemData["inventoryItem"] as? [String: Any],
////                          let inventoryItem = InventoryItem(dictionary: inventoryItemDict),
////                          let quantity = orderItemData["quantity"] as? Int,
////                          let price = orderItemData["price"] as? Double
////                    else {
////                        continue
////                    }
////                    let orderItem = OrderItem(inventoryItem: inventoryItem, quantity: quantity, price: price)
////                    orderItems.append(orderItem)
////                }
//                
//                let delivery = Delivery(address: deliveryDict["address"] as? String ?? "",
//                                        cost: deliveryDict["cost"] as? Double ?? 0.0)
//                
//                let order = Order(orderID: orderID,
//                                  customer: customer,
//                                  orderItems: orderItems,
//                                  orderDate: orderDate,
//                                  delivery: delivery,
//                                  notes: notes,
//                                  allergies: allergies,
//                                  isDelivered: isDelivered,
//                                  isPaid: isPaid)
//                
//                orders.append(order)
//            }
//            print("---> orders: \(orders)")
//            completion(orders)
//        })
//    }

    
    func convertStringToDate(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        // You may need to set the locale to "en_US_POSIX" to ensure the date format works consistently across devices.
        // dateFormatter.locale = Locale(identifier: "en_US_POSIX")

//        guard let date = dateFormatter.date(from: dateString) else {
//            throw "error converting date"
//        }
        
//        do {
//            return try dateFormatter.date(from: dateString)!
//        } catch {
//            print("Error converting date: \(error.localizedDescription)")
//        }
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
    func fetchItems_gpt(path: String, completion: @escaping ([InventoryItem]) -> ()) {
      
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

                let item = InventoryItem(
                    itemID: itemID,
                    name:  name,
                    itemPrice: itemPrice,
                    itemQuantity: itemQuantity,
                    size: size ,
                    AdditionDate: additionDate,
                    itemNotes:  itemNotes
                )
                
                items.append(item)
            }
            print("---> items: \(items)")
            completion(items)
        })
    }
    
    func fetchReceipts_gpt(path: String, completion: @escaping (Set<Receipt>) -> ()) {
        let receiptsRef = databaseRef.child(path)
        
        receiptsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            //        receiptsRef().observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else {
                print("No receipts data found")
                completion([])
                return
            }
            
            var receipts = [Receipt]()
            for (_, receiptData) in value {
                guard let receiptDict = receiptData as? [String: Any],
                      let myID = receiptDict["myID"] as? Int,
                      let orderID = receiptDict["orderID"] as? String,
                      //                      let pdfData = receiptDict["pdfData"] as? Data,
                      let dateGeneratedTimestamp = receiptDict["dateGenerated"] as? Double,
                      let paymentMethod = receiptDict["paymentMethod"] as? String,
                      let paymentDateTimestamp = receiptDict["paymentDate"] as? Double
                        
                else {
                    print("receipt else called")
                    continue
                }
                
                let dateGenerated = Date(timeIntervalSince1970: dateGeneratedTimestamp)
                let paymentDate = Date(timeIntervalSince1970: paymentDateTimestamp)
                
                let receipt = Receipt(
                    myID: myID,
                    orderID: orderID,
                    //                    pdfData: pdfData,
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
    
    func saveOrder(_ order: Order, path: String) {
        let orderRef = databaseRef.child(path).child(order.orderID)
        orderRef.setValue(order.dictionaryRepresentation())
    }
    
    func saveItem(_ item: InventoryItem, path: String) {
        let itemRef = databaseRef.child(path).child(item.id)
        itemRef.setValue(item.dictionaryRepresentation())
        
    }
    
    func saveReceipt(_ receipt: Receipt, path: String) {
        let receiptRef = databaseRef.child(path).child(receipt.orderID)
        receiptRef.setValue(receipt.dictionaryRepresentation())
    }
    
    // MARK: - Deleting data
    
    func deleteOrder(orderID: String, path: String) {
        let orderRef = databaseRef.child(path).child(orderID)
        orderRef.removeValue()
    }
    
    func deleteItem(itemID: String, path: String) {
        let itemRef = databaseRef.child(path).child(itemID)
        itemRef.removeValue()
    }
    
    func deleteReceipt(orderID: String, path: String) {
        let receiptRef = databaseRef.child(path).child(orderID)
        receiptRef.removeValue()
    }
    
    // MARK: - Updating data
    
    func updateOrderInDB(_ order: Order, path: String, completion: @escaping (Bool) -> Void) {
        let orderRef = databaseRef.child(path).child(order.orderID)
        orderRef.updateChildValues(order.dictionaryRepresentation()) { error, _ in
            completion(error == nil)
        }
    }
    
    func updateItemInDB(_ item: InventoryItem, path: String, completion: @escaping (Bool) -> Void) {
        let itemRef = databaseRef.child(path).child(item.itemID)
        itemRef.updateChildValues(item.dictionaryRepresentation()) { error, _ in
            completion(error == nil)
        }
    }
    
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
