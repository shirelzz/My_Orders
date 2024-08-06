//
//  OrdersManagement.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import Foundation
import Combine
//import Firebase
import FirebaseDatabase
import FirebaseDatabaseSwift
import FirebaseAuth

struct Customer: Codable {
    var name: String
    var phoneNumber: String
    
    init(name: String, phoneNumber: String) {
        self.name = name
        self.phoneNumber = phoneNumber
    }
    
    func dictionaryRepresentation() -> [String: Any] {
           return [
               "name": name,
               "phoneNumber": phoneNumber
           ]
       }
    
        init?(dictionary: [String: Any]) {
    
            guard let name = dictionary["name"] as? String,
                  let phoneNumber = dictionary["phoneNumber"] as? String
            else {
                return nil
            }
            self.name = name
            self.phoneNumber = phoneNumber
        }
}

struct Delivery: Codable {
    var address: String
    var cost: Double
    
    
    init(address: String, cost: Double) {
        self.address = address
        self.cost = cost
    }
    
    func dictionaryRepresentation() -> [String: Any] {
          return [
              "address": address,
              "cost": cost
          ]
      }
    
    init?(dictionary: [String: Any]) {

        guard let address = dictionary["address"] as? String,
              let cost = dictionary["cost"] as? Double
        else {
            return nil
        }
        self.address = address
        self.cost = cost
    }
}

struct OrderItem: Codable {
    var inventoryItem: InventoryItem
    var quantity: Int
    var price: Double
    
    init(inventoryItem: InventoryItem, quantity: Int, price: Double) {
            self.inventoryItem = inventoryItem
            self.quantity = quantity
            self.price = price
        }
    
    init?(dictionary: [String: Any]) {
         guard let inventoryItemDict = dictionary["inventoryItem"] as? [String: Any],
               let inventoryItem = InventoryItem(dictionary: inventoryItemDict),
               let quantity = dictionary["quantity"] as? Int,
               let price = dictionary["price"] as? Double
         else {
             return nil
         }

         self.inventoryItem = inventoryItem
         self.quantity = quantity
         self.price = price
     }
    
    func dictionaryRepresentation() -> [String: Any] {
        return [
            "inventoryItem": inventoryItem.dictionaryRepresentation(),
            "quantity": quantity,
            "price": price
        ]
    }
}



//enum DiscountType {
//    case amount
//    case percentage
//}
struct Order: Identifiable, Codable {
    
    var id: String { orderID }
    var orderID: String
    var customer: Customer
    var orderItems: [OrderItem]
//    var receiptItems: [ReceiptItem]?
    var orderDate: Date
    var delivery: Delivery
    var notes: String
    var allergies: String
    var isDelivered: Bool
    var isPaid: Bool
        
    var totalPrice: Double{
        let orderItemsTotal = orderItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        return orderItemsTotal + delivery.cost // - discount
    }
    
//       var discountAmount: Double // Discount amount in dollars
//       var discountPercentage: Double // Discount percentage
//       var discountType: DiscountType
    

//    var totalPrice: Double {
//        let dessertsTotal = desserts.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
//        let totalBeforeDiscount = dessertsTotal + delivery.cost
//        var totalWithDiscount = totalBeforeDiscount
//
//        switch discountType {
//        case .amount:
//            totalWithDiscount -= discountAmount
//        case .percentage:
//            totalWithDiscount -= totalBeforeDiscount * (discountPercentage / 100)
//        }
//
//        return max(0, totalWithDiscount) // Ensure the total is not negative
//    }
    
    var receipt: Receipt?
    
    // Default constructor
    init(orderID: String = "",
         customer: Customer = Customer(name: "No Name", phoneNumber: "0000000"),
         orderItems: [OrderItem] = [],
         orderDate: Date = Date(),
         delivery: Delivery = Delivery(address: "Null", cost: 0.0),
         notes: String = "", allergies: String = "", isDelivered: Bool = false, isPaid: Bool = false)
    {
        self.orderID = orderID
        self.customer = customer
        self.orderItems = orderItems
        self.orderDate = orderDate
        self.delivery = delivery
        self.notes = notes
        self.allergies = allergies
        self.isDelivered = isDelivered
        self.isPaid = isPaid
    }
    
    func dictionaryRepresentation() -> [String: Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        var orderDict: [String: Any] = [
            
            "orderID": orderID,
            "customer": customer.dictionaryRepresentation(), // Convert to dictionary
            "orderDate": dateFormatter.string(from: orderDate),
             "delivery": delivery.dictionaryRepresentation(), // Convert to dictionary
             "notes": notes,
             "allergies": allergies,
             "isDelivered": isDelivered,
             "isPaid": isPaid,
             "totalPrice": totalPrice,
             "receipt": receipt?.dictionaryRepresentation() ?? [:] // Convert to dictionary or empty dictionary if nil

        ]
        // Convert each OrderItem to dictionary representation
          let orderItemsDictArray = orderItems.map { $0.dictionaryRepresentation() }
          orderDict["orderItems"] = orderItemsDictArray
        return orderDict
    }
    
    init?(dictionary: [String: Any]) {
            guard
                let orderID = dictionary["orderID"] as? String,
                let customerDict = dictionary["customer"] as? [String: Any],
                let orderItemsData = dictionary["orderItems"] as? [String: [String: Any]],
                let orderDate = dictionary["orderDate"] as? Date,
                let deliveryDict = dictionary["delivery"] as? [String: Any],
                let notes = dictionary["notes"] as? String,
                let allergies = dictionary["allergies"] as? String,
                let isDelivered = dictionary["isDelivered"] as? Bool,
                let isPaid = dictionary["isPaid"] as? Bool
        else {
                return nil
            }

            // Parse customer and delivery
            guard
                let customer = Customer(dictionary: customerDict),
                let delivery = Delivery(dictionary: deliveryDict)
            else {
                return nil
            }

            // Parse orderItems
            var orderItems = [OrderItem]()
            for (_, orderItemData) in orderItemsData {
                guard
                    let inventoryItemDict = orderItemData["inventoryItem"] as? [String: Any],
                    let quantity = orderItemData["quantity"] as? Int,
                    let price = orderItemData["price"] as? Double,
                    let inventoryItem = InventoryItem(dictionary: inventoryItemDict)
                else {
                    return nil
                }

                let orderItem = OrderItem(inventoryItem: inventoryItem, quantity: quantity, price: price)
                orderItems.append(orderItem)
            }

            // Initialize the Order object
            self.init(
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
        }
}

struct Receipt: Identifiable, Codable, Hashable {
    var id: String //UUID()
    var myID: Int
    var orderID: String
    var dateGenerated: Date
    var paymentMethod: String
    var paymentDate: Date
    
    // Optional discount fields
    var discountAmount: Double?
    var discountPercentage: Double?
    
    // Default constructor
    init(id: String = "", myID: Int = 0, orderID: String = "",
         dateGenerated: Date = Date(), paymentMethod: String = "", paymentDate: Date = Date(), discountAmount: Double? = nil, discountPercentage: Double? = nil) //, pdfData: Data? = nil
    {
        self.id = id
        self.myID = myID
        self.orderID = orderID
        self.dateGenerated = dateGenerated
        self.paymentMethod = paymentMethod
        self.paymentDate = paymentDate
        self.discountAmount = discountAmount
        self.discountPercentage = discountPercentage
    }
    
    init?(dictionary: [String: Any]) {

        guard let id = dictionary["id"] as? String,
              let myID = dictionary["myID"] as? Int,
              let orderID = dictionary["orderID"] as? String,
              let dateGenerated = dictionary["dateGenerated"] as? Date,
              let paymentMethod = dictionary["paymentMethod"] as? String,
              let paymentDate = dictionary["paymentDate"] as? Date,
              let discountAmount = dictionary["discountAmount"] as? Double,
              let discountPercentage = dictionary["discountPercentage"] as? Double

        else {
            return nil
        }
        self.id = id
        self.myID = myID
        self.orderID = orderID
        self.dateGenerated = dateGenerated
        self.paymentMethod = paymentMethod
        self.paymentDate = paymentDate
        self.discountAmount = discountAmount
        self.discountPercentage = discountPercentage
    }
    
    func dictionaryRepresentation() -> [String: Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var receiptDict: [String: Any] = [
            
            "id": id, // new
            "myID": myID,
            "orderID": orderID,
            "dateGenerated": dateFormatter.string(from: dateGenerated),
            "paymentMethod": paymentMethod,
            "paymentDate": dateFormatter.string(from: paymentDate)
            
        ]
        
        if let discountAmount = discountAmount {
            receiptDict["discountAmount"] = discountAmount
        }
        
        if let discountPercentage = discountPercentage {
            receiptDict["discountPercentage"] = discountPercentage
        }
        
        return receiptDict
    }
}

struct ReceiptValues: Codable {
    var receiptNumber: Int
    var receiptNumberReset: Int
    
    init(receiptNumber: Int, receiptNumberReset: Int) {
        self.receiptNumber = receiptNumber
        self.receiptNumberReset = receiptNumberReset
    }
    
    init?(dictionary: [String: Any]) {

        guard let receiptNumber = dictionary["receiptNumber"] as? Int,
              let receiptNumberReset = dictionary["receiptNumberReset"] as? Int

        else {
            return nil
        }
        self.receiptNumber = receiptNumber
        self.receiptNumberReset = receiptNumberReset
    }
    
    func dictionaryRepresentation() -> [String: Any] {

        let receiptValuesDict: [String: Any] = [
            
            "receiptNumber": receiptNumber,
            "receiptNumberReset": receiptNumberReset

        ]
        return receiptValuesDict
    }
}


class OrderManager: ObservableObject {
    
    static var shared = OrderManager()
    @Published var orders: [Order] = []
    @Published var receipts: [Receipt] = []

    var receiptValues: ReceiptValues = ReceiptValues(receiptNumber: 0, receiptNumberReset: 0) // reset: 0 = false, 1 = true

    private var isUserSignedIn = Auth.auth().currentUser != nil


    init() {
        if isUserSignedIn{
            fetchOrders()
            fetchReceipts()
            fetchReceiptValues()
        }
        else {
            loadOrders()
            loadReceipts()
            loadReceiptValuesFromUD()
        }
    }
    
    // MARK: - For signed in users (Firebase)
    
    func fetchOrders() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/orders"

            OrderDatabaseManager.shared.fetchOrders(path: path, completion: { fetchedOrders in

                DispatchQueue.main.async {
                    self.orders = fetchedOrders
                    print("Success fetching orders")
                    
                    for order in fetchedOrders {
                        self.printOrder(order: order)
                    }
                }


            })
        }
    }
    
    func fetchReceiptValues() {
        
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/receiptSettings"

            ReceiptsDatabaseManager.shared.fetchReceiptValues(path: path, completion: { fetchedReceiptValues in
                DispatchQueue.main.async {
                    self.receiptValues = fetchedReceiptValues
                    print("Success fetching receipts values")
                }
            })
            
            if self.receiptValues.receiptNumberReset == -1 {
                let lastReceiptID = getLastReceiptID()
                self.receiptValues = ReceiptValues(receiptNumber: lastReceiptID, receiptNumberReset: 0)
                saveReceiptValues()
            }
        }
    }

    
    func fetchReceipts() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/receipts"

            ReceiptsDatabaseManager.shared.fetchReceipts(path: path, completion: { fetchedReceipts in
                DispatchQueue.main.async {
                    self.receipts = fetchedReceipts // Set(fetchedReceipts)
                    print("Success fetching receipts")
                }
            })
        }
    }
    
    func saveOrder2DB(_ order: Order) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/orders"
            OrderDatabaseManager.shared.saveOrder(order, path: path)
        }
    }

    func saveReceipt2DB(_ receipt: Receipt) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/receipts"
            ReceiptsDatabaseManager.shared.saveReceipt(receipt, path: path)
        }
    }
    
    func deleteOrderFromDB(orderID: String) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/orders"
            OrderDatabaseManager.shared.deleteOrder(orderID: orderID, path: path)
        }
    }

    func deleteReceiptFromDB(orderID: String) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/receipts"
            ReceiptsDatabaseManager.shared.deleteReceipt(orderID: orderID, path: path) // orderId?
        }
    }

    
    // MARK: - For guest users (User Defaults)
    
    // Function to load orders from UserDefaults
    func loadOrders() {
        if let savedData = UserDefaults.standard.data(forKey: "orders"),
           let decodedOrders = try? JSONDecoder().decode([Order].self, from: savedData) {
            orders = decodedOrders
            print("success decoding orders! load")
        }
        else{
            print("Error decoding orders load")
        }
        
    }
    
    func loadReceipts() {
        if let savedData = UserDefaults.standard.data(forKey: "receipts") {
            do {
                let decodedReceipts = try JSONDecoder().decode([Receipt].self, from: savedData)
                //                receipts = decodedReceipts
                receipts = decodedReceipts // Set(decodedReceipts)
                
                print("success decoding receipts! load")
            } catch {
                print("load Error decoding receipts: \(error)")
            }
        }
    }
    
    private func saveOrders2UD() {
        if let encodedData = try? JSONEncoder().encode(orders) {
            UserDefaults.standard.set(encodedData, forKey: "orders")
            print("success decoding orders! save")
        }
        else{
            print("Error decoding orders save")
        }
    }
    
    private func saveReceipts2UD() {
        do {
            let encodedData = try JSONEncoder().encode(receipts)
            UserDefaults.standard.set(encodedData, forKey: "receipts")
            print("success encoding receipts! save")
            
        } catch {
            print("save Error encoding receipts: \(error)")
        }
    }
    
    // Function to clear orders from UserDefaults (optional)
//       func clearOrders() {
//           UserDefaults.standard.removeObject(forKey: ordersKey)
//       }
    

    
    
    // MARK:  - For all users
    
    func getReceipts() -> [Receipt] {
        return self.receipts
    }
    
    func getReceipts(forYear year: Int) -> [Receipt] {
         return receipts.filter { Calendar.current.component(.year, from: $0.dateGenerated) == year }
     }
    
    // MARK: - Manage Orders

    func addOrder(order: Order) {
        orders.append(order)
        if isUserSignedIn {
            saveOrder2DB(order)
        }
        else{
            saveOrders2UD()
        }
    }
    
    func getOrders() -> [Order] {
        return orders
    }
    
    func getUpcomingOrders() -> [Order] {
        let upcomingOrders = orders.filter { !$0.isDelivered } // && $0.orderDate > Date()
        return upcomingOrders.sorted { $0.orderDate < $1.orderDate }
    }
    
    func getOrder(orderID: String) -> Order {
        if let index = orders.firstIndex(where: { $0.id == orderID }) {
            let order = orders[index]
            return order
        }
        print("error finding order")
        return Order()
    }
    
    func removeOrder(with orderID: String) {
        if let index = orders.firstIndex(where: { $0.id == orderID }) {
            orders.remove(at: index)
            
            if isUserSignedIn {
                deleteOrderFromDB(orderID: orderID)
            }
            else{
                saveOrders2UD()
            }
        }
    }
    
    func updateOrder(order: Order) {
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index] = order

            if isUserSignedIn {
                if let currentUser = Auth.auth().currentUser {
                    let userID = currentUser.uid
                    let path = "users/\(userID)/orders/\(orders[index].orderID)"
                    
                    OrderDatabaseManager.shared.updateOrderInDB(order, path: path) { success in
                        if !success {
                            print("updating in the database failed")
                        }
                    }
                }
            } else {
                saveOrders2UD()
            }
        }
    }

    
    
    func updateOrderStatus(orderID: String, isDelivered: Bool) {
        if let index = orders.firstIndex(where: { $0.id == orderID }) {
            orders[index].isDelivered = isDelivered
            
            if isUserSignedIn {
                if let currentUser = Auth.auth().currentUser {
                    let userID = currentUser.uid
                    let path = "users/\(userID)/orders/\(orders[index].orderID)"
                    
                    OrderDatabaseManager.shared.updateOrderInDB(orders[index], path: path) { success in
                        if !success {
                            print("updating in the database failed")
                        }
                    }
                }
            } else {
                saveOrders2UD()
            }
        }
    }
    
    func updatePaymentStatus(orderID: String, isPaid: Bool) {
        if let index = orders.firstIndex(where: { $0.id == orderID }) {
            if !receiptExists(forOrderID: orders[index].orderID) {
                orders[index].isPaid = isPaid
                
                if isUserSignedIn {
                    if let currentUser = Auth.auth().currentUser {
                        let userID = currentUser.uid
                        let path = "users/\(userID)/orders/\(orders[index].orderID)"
                        
                        OrderDatabaseManager.shared.updateOrderInDB(orders[index], path: path) { success in
                            if !success {
                                print("updating in the database failed")
                            }
                        }
                    }
                } else {
                    saveOrders2UD()
                }
            }
        }
    }
    
    func clearDeliveredOrders() {
        orders.removeAll { $0.isDelivered }
        if isUserSignedIn {
            // Clear data from the database
            // Implement the logic to remove delivered orders from the database
        } else {
            // Clear data from UserDefaults
            UserDefaults.standard.removeObject(forKey: "user_orders_key")
        }
    }

    func printOrder(order: Order) -> Void {
        print("> orderID: \(order.orderID)")
        print("> ispaid: \(order.isPaid.description)")
        
        if let receipt = order.receipt {
            print("> receipt details: ")
            
            print("> id: \(receipt.id)")
            print("> myID: \(receipt.myID)")
            print("> orderID: \(receipt.orderID)")
            print("> dateGenerated: \(receipt.dateGenerated)")
            print("> paymentMethod: \(receipt.paymentMethod)")
            print("> paymentDate: \(receipt.paymentDate)")
        } else {
            print("> Receipt is nil")
        }
        
    }
    
    
    // MARK: - Manage Receipts
    
    func addReceipt(receipt: Receipt) {
        if !receipts.contains(receipt) {
            receipts.append(receipt) // .insert(receipt)
            
            if isUserSignedIn {
                saveReceipt2DB(receipt)
            } else {
                saveReceipts2UD()
            }
        }
    }
    
    func assignReceiptToOrder(receipt: Receipt, toOrderWithID orderID: String) -> Order? {
        if let index = orders.firstIndex(where: { $0.orderID == orderID }) {
            orders[index].receipt = receipt
            return orders[index]
        }
        return nil
    }
    
    func getReceipt(forOrderID orderID: String) -> Receipt {
        if let receipt = receipts.first(where: { $0.orderID == orderID }) {
            return receipt
        } else {
            return Receipt()
        }
    }
    
    func getOrderFromID(forOrderID orderID: String) -> Order {
        if let order = orders.first(where: { $0.orderID == orderID }) {
            return order
        } else {
            return Order()
        }
    }
    
    func receiptExists(forOrderID orderID: String) -> Bool {
        
        if receipts.first(where: { $0.orderID == orderID }) != nil {
            return true
        } else {
            return false
        }
    }
    
    func getLastReceipt() -> Receipt? {
        // Get the most recently generated receipt by sorting receipts based on dateGenerated
        if let lastReceipt = receipts.sorted(by: { $0.dateGenerated > $1.dateGenerated }).first{
            printReceipt(receipt: lastReceipt)
            return lastReceipt
        }
        else{
            return Receipt(id: "000", myID: 000, orderID: "000" , dateGenerated: Date(), paymentMethod: "", paymentDate: Date())
        }
    }
    
    func getLastReceiptID() -> Int {
        print("--- getLastReceiptID -> receiptNumberReset = \(receiptValues.receiptNumberReset)")
        if (self.receiptValues.receiptNumberReset == 0 || self.receiptValues.receiptNumberReset == -1) { // reset = false
            guard let lastReceipt = receipts.max(by: { $0.myID < $1.myID }) else {
                return 0
            }
            print("--- getLastReceiptID -> lastReceipt.myID = \(lastReceipt.myID)")
            return lastReceipt.myID
        }
        else if (self.receiptValues.receiptNumberReset == 1) {
            return self.receiptValues.receiptNumber - 1
        }
        else{
            return -1
        }
    }
    
    func forceReceiptNumberReset(value: Int) {
        print("--- forceReceiptNumberReset 1 -> receiptNumberReset = \(receiptValues.receiptNumberReset)")
        self.receiptValues.receiptNumberReset = value
        print("--- forceReceiptNumberReset 2 -> receiptNumberReset = \(receiptValues.receiptNumberReset)")
        saveReceiptValues()
        print("--- forceReceiptNumberReset 3 -> receiptNumberReset = \(receiptValues.receiptNumberReset)")
    }
    
    func toggleReceiptNumberReset() {
        if self.receiptValues.receiptNumberReset == 1 {
            self.receiptValues.receiptNumberReset = 0
        }
        else if self.receiptValues.receiptNumberReset == 0 {
            self.receiptValues.receiptNumberReset = 1
        }
        
        saveReceiptValues()
    }
    
    func updateReceiptValues() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/receiptSettings"

            ReceiptsDatabaseManager.shared.saveOrUpdateReceiptValuesInDB(self.receiptValues, path: path, completion: { _ in
            })
        }
    }
    
    func setStartingReceiptNumber(_ newNumber: Int) {
        self.receiptValues.receiptNumber = newNumber
        self.receiptValues.receiptNumberReset = 1
        saveReceiptValues()
    }
    
    func saveReceiptValues() {
        
        if isUserSignedIn {
            updateReceiptValues()
        }
        else{
            saveReceiptValuesToUD(values: self.receiptValues)
        }
    }
    
    func saveReceiptValuesToUD(values: ReceiptValues) {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(values) {
            UserDefaults.standard.set(encodedData, forKey: "receiptValues")
        }
    }

    func loadReceiptValuesFromUD() {
        if let encodedData = UserDefaults.standard.data(forKey: "receiptValues") {
            let decoder = JSONDecoder()
            if let decodedValues = try? decoder.decode(ReceiptValues.self, from: encodedData) {
                self.receiptValues = decodedValues
            }
        }
    }
    
    func printReceipt(receipt: Receipt){
        print("generated receipt details: ")
        print("id: \(receipt.id)")
        print("myID: \(receipt.myID)")
        print("orderID: \(receipt.orderID)")
        print("dateGenerated: \(receipt.dateGenerated)")
        print("paymentMethod: \(receipt.paymentMethod)")
        print("paymentDate: \(receipt.paymentDate)")
    }
    
}

