//
//  OrdersManagement.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import Foundation
import Combine
import UserNotifications


struct Customer: Codable {
    var name: String
    var phoneNumber: Int
}

struct Delivery: Codable {
    var address: String
    var cost: Double
}

struct Dessert: Codable {
    var inventoryItem: InventoryItem
    var quantity: Int
    var price: Double
}

struct Order: Identifiable, Codable {
    
    var id: String { orderID }
    
    var orderID: String
    var customer: Customer
    var desserts: [Dessert]
    var orderDate: Date
    var delivery: Delivery
    var notes: String
    var allergies: String
    var isDelivered: Bool
    var isPaid: Bool
    
    var totalPrice: Double{
        let dessertsTotal = desserts.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        return dessertsTotal + delivery.cost
    }
    
    var receipt: Receipt? // maybe i should do it ?
    
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
    
    //    func removeOrder(at index: Int) {
    //        orders.remove(at: index)
    //        saveOrders()
    //    }
    
    func removeOrder(with orderID: String) {
        if let index = orders.firstIndex(where: { $0.id == orderID }) {
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
    
    
    
    //    var receipts: [Receipt] {
    //        get {
    //            if let savedData = UserDefaults.standard.data(forKey: "receipts"),
    //               let decodedReceipts = try? JSONDecoder().decode([Receipt].self, from: savedData) {
    //                return decodedReceipts
    //            }
    //            return []
    //        }
    //        set {
    //            if let encodedReceipts = try? JSONEncoder().encode(newValue) {
    //                UserDefaults.standard.set(encodedReceipts, forKey: "receipts")
    //            }
    //        }
    //    }
    
    
    // Function to add and save a receipt
    func addReceipt(receipt: Receipt) {
        if !generatedReceiptIDs.contains(receipt.orderID) {
            //            receipts.append(receipt)
            receipts.insert(receipt)
            
            generatedReceiptIDs.insert(receipt.orderID)
            saveReceipts()
        }
    }
    
//    func assignReceiptToOrder(receipt: Receipt, toOrderWithID orderID: String) {
//        if let index = orders.firstIndex(where: { $0.id == orderID }) { //{ $0.id == orderID }
//            orders[index].receipt = receipt
//        }
//    }
    
//    func assignReceiptToOrder(receipt: Receipt, toOrderWithID orderID: String, completion: @escaping () -> Void) {
//        if let index = orders.firstIndex(where: { $0.orderID == orderID }) {
//            orders[index].receipt = receipt
//            completion() // Call the completion handler
//        }
//    }
    
    func assignReceiptToOrder(receipt: Receipt, toOrderWithID orderID: String) -> Order? {
        if let index = orders.firstIndex(where: { $0.orderID == orderID }) {
            orders[index].receipt = receipt
            return orders[index]
        }
        return nil
    }
    
//    func getReceipt(forOrderID orderID: String) -> Receipt? {
//            if let order = orders.first(where: { $0.id == orderID }),
//               let receipt = order.receipt {
//                return receipt
//            }
//            return nil
//        }
    
//    func getReceipt(forOrderID orderID: String) -> Receipt? {
//        return receipts.first(where: { $0.orderID == orderID })
//    }
    
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



    
    //    // Function to save receipts to UserDefaults
    //    private func saveReceipts() {
    //        if let encodedData = try? JSONEncoder().encode(receipts) {
    //            UserDefaults.standard.set(encodedData, forKey: "receipts")
    //        }
    //    }
    //
    //    // Function to load receipts from UserDefaults
    //    func loadReceipts() {
    //        if let savedData = UserDefaults.standard.data(forKey: "receipts"),
    //           let decodedReceipts = try? JSONDecoder().decode([Receipt].self, from: savedData) {
    //            receipts = decodedReceipts
    //        }
    //    }
    
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
                
                print("load success decoding receipts!")
            } catch {
                print("load Error decoding receipts: \(error)")
            }
        }
    }
    
    func receiptExists(forOrderID orderID: String) -> Bool {
//        return generatedReceiptIDs.contains(orderID)
        
//        if let receipt = receipts.first(where: { $0.orderID == orderID }) {
//            return true
//        } else {
//            return false
//        } worked
        
        
        if receipts.first(where: { $0.orderID == orderID }) != nil {
            return true
        } else {
            return false
        }
    }
    
    //    func receiptExists(forReceipt receipt: Receipt) -> Bool {
    //        return receipts.contains(receipt)
    //    }
    
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
        // Get the most recently generated receipt by sorting receipts based on dateGenerated
        guard let lastReceipt = receipts.sorted(by: { $0.dateGenerated > $1.dateGenerated }).first else {
            return 0
        }
        return lastReceipt.myID
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
    
    //    func getLastReceiptID() -> Int {
    //        // Get the most recently generated receipt by sorting receipts based on dateGenerated
    //        guard let lastReceipt = receipts.sorted(by: { $0.myID > $1.myID }).first else {
    //            return 0
    //        }
    //        return lastReceipt.myID
    //    }
    
    
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

