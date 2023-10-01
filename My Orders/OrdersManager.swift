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

//    var city: String
//    var street: String
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
    var totalPrice: Double {
        let dessertsTotal = desserts.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        return dessertsTotal + delivery.cost
    }
    
//    // Implement the Encodable protocol methods
//       enum CodingKeys: String, CodingKey {
//           case id, customer, desserts, orderDate, delivery, notes, allergies, isCompleted, totalPrice
//       }
//
//       func encode(to encoder: Encoder) throws {
//           var container = encoder.container(keyedBy: CodingKeys.self)
//
//           try container.encode(id, forKey: .id)
//           try container.encode(customer, forKey: .customer)
//           try container.encode(desserts, forKey: .desserts)
//           try container.encode(orderDate, forKey: .orderDate)
//           try container.encode(delivery, forKey: .delivery)
//           try container.encode(notes, forKey: .notes)
//           try container.encode(allergies, forKey: .allergies)
//           try container.encode(isCompleted, forKey: .isCompleted)
//           try container.encode(totalPrice, forKey: .totalPrice)
//
//       }
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

    // Initialization
    init() {
        // Load orders from UserDefaults when the manager is initialized
        loadOrders()
    }
    
    func updateOrderStatus(orderID: String, isCompleted: Bool) {
            if let index = orders.firstIndex(where: { $0.id == orderID }) {
                orders[index].isCompleted = isCompleted
                saveOrders()
            }
        }
    
}

