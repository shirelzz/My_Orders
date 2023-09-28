//
//  OrdersManagement.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import Foundation

struct Dessert {
    var dessertName: String
    var quantity: Int
    var price: Double

}

struct DessertOrder {
    var orderID: String
    var customerName: String
    var desserts: [Dessert] // An array to store multiple desserts per order
    var orderDate: Date
    var isCompleted: Bool
    var totalPrice: Double {
        return desserts.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
}

class OrderManager {
    static var shared = OrderManager()
    
    private var orders: [DessertOrder] = []
    
    func addOrder(order: DessertOrder) {
        orders.append(order)
    }
    
    func getOrders() -> [DessertOrder] {
        return orders
    }
    
    // Add other functions for editing and deleting orders as needed
}

