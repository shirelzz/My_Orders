//
//  OrdersManagement.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import Foundation
import Combine
import UserNotifications
//import Firebase
import FirebaseDatabase
import FirebaseDatabaseSwift

struct Customer: Codable {
    var name: String
    var phoneNumber: String
}

struct Delivery: Codable {
    var address: String
    var cost: Double
}

struct OrderItem: Codable {
    var inventoryItem: InventoryItem
    var quantity: Int
    var price: Double
}

//enum DiscountType {
//    case amount
//    case percentage
//}
struct Order: Identifiable, Codable {
    
    var id: String { orderID }
    
    var orderID: String
    var customer: Customer
    var desserts: [OrderItem]
    var orderDate: Date
    var delivery: Delivery
    var notes: String
    var allergies: String
    var isDelivered: Bool
    var isPaid: Bool

    
    var totalPrice: Double{
        let dessertsTotal = desserts.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        return dessertsTotal + delivery.cost // - discount
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
    init(orderID: String = "", customer: Customer = Customer(name: "No Name", phoneNumber: "0000000"), desserts: [OrderItem] = [], orderDate: Date = Date(), delivery: Delivery = Delivery(address: "No where", cost: 1000.0), notes: String = "", allergies: String = "", isDelivered: Bool = false, isPaid: Bool = false) {
        self.orderID = orderID
        self.customer = customer
        self.desserts = desserts
        self.orderDate = orderDate
        self.delivery = delivery
        self.notes = notes
        self.allergies = allergies
        self.isDelivered = isDelivered
        self.isPaid = isPaid
    }
    
}

struct Receipt: Identifiable, Codable, Hashable {
    var id: String //UUID()
    var myID: Int
    var orderID: String
    var pdfData: Data?
    var dateGenerated: Date
    var paymentMethod: String
    var paymentDate: Date
}


class OrderManager: ObservableObject {
    
    static var shared = OrderManager()
    @Published var orders: [Order] = []
    @Published var receipts: Set<Receipt> = Set()
    private var generatedReceiptIDs: Set<String> = Set()
    private var receiptNumber = 0
    private var receiptNumberReset = 0 // 0 = false, 1 = true

    init() {
        loadOrders()
        loadReceipts()
    }
    
    func addOrder(order: Order) {
        orders.append(order)
        saveOrders()
    }
    
    func getOrders() -> [Order] {
        return orders
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
            
            for dessert in orders[index].desserts {
                InventoryManager.shared.updateQuantity(
                    item: dessert.inventoryItem,
                    newQuantity: dessert.inventoryItem.itemQuantity + dessert.quantity
                )
            }
            
            orders.remove(at: index)
            saveOrders()
        }
    }
    
    private func saveOrders() {
        if let encodedData = try? JSONEncoder().encode(orders) {
            UserDefaults.standard.set(encodedData, forKey: "orders")
            print("success decoding orders! save")
        }
        else{
            print("Error decoding orders save")
        }
    }
    
    // Save orders to Firebase
    private func saveOrders2Firebase() {
        let ordersRef = Database.database().reference().child("orders")
        
        do {
            let encodedData = try JSONEncoder().encode(orders)
            let orderArray = try JSONSerialization.jsonObject(with: encodedData) as! [[String: Any]]
            
            ordersRef.setValue(orderArray)
            print("Success saving orders to Firebase!")
        } catch {
            print("Error encoding or saving orders to Firebase: \(error)")
        }
    }

    
    // Retrieve orders from Firebase
    private func fetchOrdersFromFirebase() {
        let ordersRef = Database.database().reference().child("orders")
        
        ordersRef.observeSingleEvent(of: .value) { snapshot in
            guard let orderArray = snapshot.value as? [[String: Any]] else {
                print("Invalid data format from Firebase")
                return
            }

            do {
                let decodedOrders = try JSONDecoder().decode([Order].self, from: JSONSerialization.data(withJSONObject: orderArray))
                self.orders = decodedOrders
                print("Success fetching orders from Firebase!")
            } catch {
                print("Error decoding or updating orders from Firebase: \(error)")
            }
        }
    }

    
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
    
    func updateOrder(order: Order) {
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index] = order
            saveOrders()
        }
    }
    
    
    func updateOrderStatus(orderID: String, isDelivered: Bool) {
        if let index = orders.firstIndex(where: { $0.id == orderID }) {
            if !receiptExists(forOrderID: orders[index].orderID) {
                orders[index].isDelivered = isDelivered
                saveOrders()
            }
        }
    }
    
    func updatePaymentStatus(orderID: String, isPaid: Bool) {
        if let index = orders.firstIndex(where: { $0.id == orderID }) {
            if !receiptExists(forOrderID: orders[index].orderID) {
                orders[index].isPaid = isPaid
                saveOrders()
            }
        }
    }
        
    func printOrder(order: Order) -> Bool {
        print("orderID: \(order.orderID)")
        print("ispaid: \(order.isPaid.description)")
        
        if let receipt = order.receipt {
            print("receipt details: ")
            
            print("id: \(receipt.id)")
            print("myID: \(receipt.myID)")
            print("orderID: \(receipt.orderID)")
            print("dateGenerated: \(receipt.dateGenerated)")
            print("paymentMethod: \(receipt.paymentMethod)")
            print("paymentDate: \(receipt.paymentDate)")
        } else {
            print("Receipt is nil")
        }
        
        return false
    }
    
    // Function to add and save a receipt
    func addReceipt(receipt: Receipt) {
        if !generatedReceiptIDs.contains(receipt.orderID) {
            //            receipts.append(receipt)
            receipts.insert(receipt)
            
            generatedReceiptIDs.insert(receipt.orderID)
            saveReceipts()
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
            // Return a default or placeholder Receipt if no matching receipt is found
            return Receipt(
                id: UUID().uuidString,
                myID: 0,
                orderID: orderID,
                pdfData: nil,
                dateGenerated: Date(),
                paymentMethod: "",
                paymentDate: Date()
            )
        }
    }
    
    private func saveReceipts() {
        do {
            let encodedData = try JSONEncoder().encode(receipts)
            UserDefaults.standard.set(encodedData, forKey: "receipts")
            print("success encoding receipts! save")
            
        } catch {
            print("save Error encoding receipts: \(error)")
        }
    }
    
    func loadReceipts() {
        if let savedData = UserDefaults.standard.data(forKey: "receipts") {
            do {
                let decodedReceipts = try JSONDecoder().decode([Receipt].self, from: savedData)
                //                receipts = decodedReceipts
                receipts = Set(decodedReceipts)
                
                print("success decoding receipts! load")
            } catch {
                print("load Error decoding receipts: \(error)")
            }
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
        
        if (receiptNumberReset == 0) {
            // Get the most recently generated receipt by sorting receipts based on dateGenerated
            guard let lastReceipt = receipts.sorted(by: { $0.dateGenerated > $1.dateGenerated }).first else {
                return 0
            }
            return lastReceipt.myID
        }
        else {
            receiptNumberReset = 0
            return receiptNumber - 1
        }
    }
    
    func setStartingReceiptNumber(_ newNumber: Int) {
        receiptNumber = newNumber
        receiptNumberReset = 1
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
    
    // notifications
    func scheduleOrderNotification(order: Order, daysBefore: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Order Time is Soon"
        content.body = "Your order \(order.orderID) is coming up in \(daysBefore) days."
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: order.orderDate) ?? Date()
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: order.orderID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}

