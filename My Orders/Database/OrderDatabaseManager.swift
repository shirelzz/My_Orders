//
//  OrderDatabaseManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/04/2024.
//

import Foundation

class OrderDatabaseManager: DatabaseManager {
    
    static var shared = OrderDatabaseManager()
    
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
                    print("stopped middle way: ")
                    continue
                }
                
                let customer = Customer(name: customerDict["name"] as? String ?? "",
                                        phoneNumber: customerDict["phoneNumber"] as? String ?? "")

                print("customer name: \(customer.name)")
                
                let delivery = Delivery(
                    address: deliveryDict["address"] as? String ?? "",
                    cost: deliveryDict["cost"] as? Double ?? 0.0
                )
                
                let orderDate = self.convertStringToDateAndTime(orderDateStr)

                var orderItems = [OrderItem]()
                for orderItemData in orderItemsData {
                    guard let inventoryItemDict = orderItemData["inventoryItem"] as? [String: Any],
                          
                          let quantity = orderItemData["quantity"] as? Int,
                          let price = orderItemData["price"] as? Double,
                          
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

                                             
                    let additionDate = self.convertStringToDate(additionDateStr)

                    var tags: [String]? = nil
                    if let parsedTags = inventoryItemDict["tags"] as? [String] {
                        tags = parsedTags
                    }
                    let inventoryItem = InventoryItem(
                        itemID: itemID,
                        name:  name,
                        itemPrice: itemPrice,
                        itemQuantity: itemQuantity,
                        size: size ,
                        AdditionDate: additionDate,
                        itemNotes:  itemNotes,
                        tags: tags
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
    
    // MARK: - Writing data
    
    func saveOrder(_ order: Order, path: String) {
        let orderRef = databaseRef.child(path).child(order.orderID)
        orderRef.setValue(order.dictionaryRepresentation())
    }
    
    // MARK: - Updating data
    
    func updateOrderInDB(_ order: Order, path: String, completion: @escaping (Bool) -> Void) {
        let orderRef = databaseRef.child(path)
        orderRef.updateChildValues(order.dictionaryRepresentation()) { error, _ in
            completion(error == nil)
        }
    }

    // MARK: - Deleting data
    
    func deleteOrder(orderID: String, path: String) {
        let orderRef = databaseRef.child(path).child(orderID)
        orderRef.removeValue()
    }
}
