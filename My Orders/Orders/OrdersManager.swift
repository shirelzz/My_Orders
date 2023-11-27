//
//  OrdersManagement.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import Foundation
import Combine


struct Customer: Codable {
    var name: String
    var phoneNumber: Int
}

struct Delivery: Codable {
    var address: String
    var cost: Double
}

struct Dessert: Codable {
    var dessertName: String
    var quantity: Int
    var price: Double
    
}

struct DessertOrder: Identifiable, Codable {
    
    var id: String { orderID }
    
    var orderID: String
    var customer: Customer
    var desserts: [Dessert]
    var orderDate: Date
    var delivery: Delivery
    var notes: String
    var allergies: String
    var isCompleted: Bool
    var isPaid: Bool
    
    var totalPrice: Double {
        let dessertsTotal = desserts.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        return dessertsTotal + delivery.cost
    }
    
    var receipt: Receipt?
    
}

struct Receipt: Identifiable, Codable {
    var id = UUID()
    var myID: Int
    var orderID: String
    var pdfData: Data?
    var dateGenerated: Date
    var paymentMethod: String
    var paymentDate: Date
}



class OrderManager: ObservableObject {
    
    static var shared = OrderManager()
    @Published var orders: [DessertOrder] = []
    
    func addOrder(order: DessertOrder) {
        orders.append(order)
        saveOrders()
    }
    
    func getOrders() -> [DessertOrder] {
        return orders
    }
    
    func removeOrder(at index: Int) {
        orders.remove(at: index)
        saveOrders()
    }
    
    private func saveOrders() {
        if let encodedData = try? JSONEncoder().encode(orders) {
            UserDefaults.standard.set(encodedData, forKey: "orders")
        }
    }
    
    // Function to load orders from UserDefaults
    func loadOrders() {
        if let savedData = UserDefaults.standard.data(forKey: "orders"),
           let decodedOrders = try? JSONDecoder().decode([DessertOrder].self, from: savedData) {
            orders = decodedOrders
        }
    }
    
    init() {
        // Load orders from UserDefaults when the manager is initialized
        loadOrders()        
    }
    
    func updateOrderStatus(orderID: String, isCompleted: Bool) {
        if let index = orders.firstIndex(where: { $0.id == orderID }) {
            if !receiptExists(forOrderID: orders[index].orderID) {
                orders[index].isCompleted = isCompleted
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
    
    
    private var generatedReceiptIDs: Set<String> = Set()
    
    var receipts: [Receipt] {
        get {
            if let savedData = UserDefaults.standard.data(forKey: "receipts"),
               let decodedReceipts = try? JSONDecoder().decode([Receipt].self, from: savedData) {
                return decodedReceipts
            }
            return []
        }
        set {
            if let encodedReceipts = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encodedReceipts, forKey: "receipts")
            }
        }
    }
    
    
    // Function to add and save a receipt
    func addReceipt(receipt: Receipt) {
        if !generatedReceiptIDs.contains(receipt.orderID) {
            receipts.append(receipt)
            generatedReceiptIDs.insert(receipt.orderID)
            saveReceipts()
        }
    }
    
    func assignReceiptToOrder(receipt: Receipt, toOrderWithID orderID: String) {
        if let index = orders.firstIndex(where: { $0.id == orderID }) {
            orders[index].receipt = receipt
        }
    }
    
    // Function to save receipts to UserDefaults
    private func saveReceipts() {
        if let encodedData = try? JSONEncoder().encode(receipts) {
            UserDefaults.standard.set(encodedData, forKey: "receipts")
        }
    }
    
    // Function to load receipts from UserDefaults
    func loadReceipts() {
        if let savedData = UserDefaults.standard.data(forKey: "receipts"),
           let decodedReceipts = try? JSONDecoder().decode([Receipt].self, from: savedData) {
            receipts = decodedReceipts
        }
    }
    
    func receiptExists(forOrderID orderID: String) -> Bool {
        return generatedReceiptIDs.contains(orderID)
    }
    
    func getLastReceipt() -> Receipt? {
        // Get the most recently generated receipt by sorting receipts based on dateGenerated
        return receipts.sorted(by: { $0.dateGenerated > $1.dateGenerated }).first
    }
    
    func getLastReceiptID() -> Int {
        // Get the most recently generated receipt by sorting receipts based on dateGenerated
        guard let lastReceipt = receipts.sorted(by: { $0.dateGenerated > $1.dateGenerated }).first else {
                return 0
            }
        return lastReceipt.myID    }
}

