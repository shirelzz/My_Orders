//
//  OrdersManagement.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import Foundation
import Combine


struct Customer {
    var name: String
    var phoneNumber: Int
}

struct Delivery {
    var address: String
    var cost: Double
}

struct Dessert {
    var dessertName: String
    var quantity: Int
    var price: Double

}

struct DessertOrder: Identifiable {
    var id: String { orderID }

    var orderID: String
    var customer: Customer
    var desserts: [Dessert] // An array to store multiple desserts per order
    var orderDate: Date
    var delivery: Delivery
    var notes: String
    var allergies: String
    var isCompleted: Bool
    var totalPrice: Double {
        let dessertsTotal = desserts.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        return dessertsTotal + delivery.cost
    }
}

class OrderManager: ObservableObject {
    static var shared = OrderManager()
    
    @Published private var orders: [DessertOrder] = []
    
    func addOrder(order: DessertOrder) {
        orders.append(order)
    }
    
    func getOrders() -> [DessertOrder] {
        return orders
    }
    
//    func deleteOrder() -> [DessertOrder] {
//        return orders.remove(at: <#T##Int#>)
//    }
    
    // Add other functions for editing and deleting orders as needed
}

