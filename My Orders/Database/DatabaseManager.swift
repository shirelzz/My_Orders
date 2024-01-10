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
    
    func fetchOrders(path: String, completion: @escaping ([Order]) -> ()) {
        let ordersRef = databaseRef.child(path)

        ordersRef.observeSingleEvent(of: .value, with: { (snapshot) in

            guard let value = snapshot.value as? [String: Any] else {
                print("No orders data found")
                completion([])
                return
            }

            var orders = [Order]()
            for (_, orderData) in value {
                guard let orderDict = orderData as? [String: Any],
                      let orderID = orderDict["orderID"] as? String,
                      let customerDict = orderDict["customer"] as? [String: Any],
                      let orderItemsData = orderDict["orderItems"] as? [[String: Any]],
                      let orderDateStr = orderDict["orderDate"] as? String,
                      let deliveryDict = orderDict["delivery"] as? [String: Any],
                      let notes = orderDict["notes"] as? String,
                      let allergies = orderDict["allergies"] as? String,
                      let isDelivered = orderDict["isDelivered"] as? Bool,
                      let isPaid = orderDict["isPaid"] as? Bool
                else {
                    print("stopped middle way")
                    continue
                }
                
                let customer = Customer(name: customerDict["name"] as? String ?? "",
                                        phoneNumber: customerDict["phoneNumber"] as? String ?? "")

                let delivery = Delivery(
                    address: deliveryDict["address"] as? String ?? "",
                    cost: deliveryDict["cost"] as? Double ?? 0.0
                )
                
                let orderDate = self.convertStringToDateAndTime(orderDateStr)
//                print("order date str: \(orderDateStr)")
//                print("order date: \(orderDate)")


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
                         
                    orderItems.append(orderItem)
                }

                let order = Order(
                    orderID: orderID,
                    customer: customer,
                    orderItems: orderItems,
                    orderDate: orderDate ?? Date(),
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
            completion(items)
        })
    }
    
    func fetchReceipts(path: String, completion: @escaping ([Receipt]) -> ()) { // Set<Receipt>
        let receiptsRef = databaseRef.child(path)
        
        receiptsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else {
                print("No receipts data found")
                completion([])
                return
            }
            
            var receipts = [Receipt]()
            for (_, receiptData) in value {
                guard let receiptDict = receiptData as? [String: Any],
                      let id = receiptDict["id"] as? String,
                      let myID = receiptDict["myID"] as? Int,
                      let orderID = receiptDict["orderID"] as? String,
                      //                      let pdfData = receiptDict["pdfData"] as? Data,
                      let dateGeneratedStr = receiptDict["dateGenerated"] as? String,
                      let paymentMethod = receiptDict["paymentMethod"] as? String,
                      let paymentDateStr = receiptDict["paymentDate"] as? String
                        
                else {
                    print("receipt else called")
                    continue
                }
                
                let dateGenerate = self.convertStringToDate(dateGeneratedStr)
                let paymentDate =  self.convertStringToDate(paymentDateStr)
                
                let receipt = Receipt(
                    id: id,
                    myID: myID,
                    orderID: orderID,
                    //                    pdfData: pdfData,
                    dateGenerated: dateGenerate,
                    paymentMethod: paymentMethod,
                    paymentDate: paymentDate
                )
                
                receipts.append(receipt)
            }
            
            completion(receipts) // Set(receipts)
        })
    }
    
    func fetchNotificationSettings(path: String, completion: @escaping (Notifications) -> ()) {
        
        let notificationsRef = databaseRef.child(path)
        
        notificationsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let value = snapshot.value as? [String: Any],
                  let daysBeforeOrderTime = value["daysBeforeOrderTime"] as? Int,
                  let inventoryQuantityThreshold = value["inventoryQuantityThreshold"] as? Int
            else {
                print("No notification settings data found")
                completion(Notifications(daysBeforeOrderTime: 1, inventoryQuantityThreshold: 0))
                return
            }
            
            let notificationSettings = Notifications(
                daysBeforeOrderTime: daysBeforeOrderTime,
                inventoryQuantityThreshold: inventoryQuantityThreshold
            )
            
            completion(notificationSettings)
        })
    }
    
    func fetchCurrency(path: String, completion: @escaping (String) -> ()) {
        
        let currencyRef = databaseRef.child(path)
        
        currencyRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let currency = snapshot.value as? String else {
                print("No currency data found")
                completion("USD")
                return
            }
            
            completion(currency)
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
    
    func saveNotificationSettings(_ notificationSettings: Notifications, path: String) {
        let notificationSettingsRef = databaseRef.child(path)
        notificationSettingsRef.setValue(notificationSettings.dictionaryRepresentation())
    }
    
    func saveCurrency(_ currency: String, path: String) {
        let currencyRef = databaseRef.child(path)
        currencyRef.setValue(currency) { error, _ in
            if let error = error {
                print("Error saving currency: \(error.localizedDescription)")
            } else {
                print("Currency saved successfully")
            }
        }
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


    
    // MARK: - Updating data
    
    func updateOrderInDB(_ order: Order, path: String, completion: @escaping (Bool) -> Void) {
        let orderRef = databaseRef.child(path)
        orderRef.updateChildValues(order.dictionaryRepresentation()) { error, _ in
            completion(error == nil)
        }
    }
    
    func updateItemInDB(_ item: InventoryItem, path: String, completion: @escaping (Bool) -> Void) {
        let itemRef = databaseRef.child(path)
        itemRef.updateChildValues(item.dictionaryRepresentation()) { error, _ in
            completion(error == nil)
        }
    }
    
    // MARK: - Helper Functions
    
    func convertStringToDate(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
//    func convertStringToDateAndTime(_ dateString: String) -> Date {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        return dateFormatter.date(from: dateString) ?? Date()
//    }
    
    func convertStringToDateAndTime(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //HH:mm
        return dateFormatter.date(from: dateString)
    }

    //i dont understand why the items quantity doesnt update when i delete an order

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
