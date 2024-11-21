//
//  OrdersManagerTests.swift
//  My OrdersTests
//
//  Created by שיראל זכריה on 20/11/2024.
//

import XCTest
@testable import My_Orders

class TestOrderManager: OrderManager {
    override init() {
        super.init()
        // Do not load orders from UserDefaults or Firebase
        orders = []
    }
}


final class OrdersManagerTests: XCTestCase {

    
    func testOrderManagerInitialization() {
        let orderManager = TestOrderManager()
        XCTAssertEqual(orderManager.orders.count, 0, "OrderManager should contain 0 orders")
    }

    
    func testAddOrderWithEmptyOrder() {
        let orderManager = TestOrderManager()
        let order = Order()

        orderManager.addOrder(order: order)

        XCTAssertEqual(orderManager.orders.count, 0, "OrderManager should contain 0 orders after adding")
    }

    func testAddOrder() {
        let orderManager = TestOrderManager()
        let customer = Customer(name: "Test User", phoneNumber: "1234567890")
        let delivery = Delivery(address: "", cost: 0)
        let item = InventoryItem(itemID: "123", name: "cake", itemPrice: 120, itemQuantity: 20, size: "20 cm", AdditionDate: Date(), itemNotes: "Dairy")
        let orderItems = [OrderItem(inventoryItem: item, quantity: 1, price: item.itemPrice)]
        let order = Order(orderID: "123543534365", customer: customer, orderItems: orderItems, orderDate: Date(), delivery: delivery, notes: "", allergies: "", isDelivered: false, isPaid: false)

        orderManager.addOrder(order: order)

        XCTAssertEqual(orderManager.orders.count, 1, "OrderManager should contain 1 order after adding")
        XCTAssertEqual(orderManager.orders.first?.customer.name, "Test User", "Customer name should match")
    }
    
    func testRetreivedOrder() {
        let orderManager = TestOrderManager()
        let customer = Customer(name: "Test User", phoneNumber: "1234567890")
        let delivery = Delivery(address: "", cost: 0)
        let item = InventoryItem(itemID: "123", name: "cake", itemPrice: 120, itemQuantity: 20, size: "20 cm", AdditionDate: Date(), itemNotes: "Dairy")
        let orderItems = [OrderItem(inventoryItem: item, quantity: 1, price: item.itemPrice)]
        let order = Order(orderID: "123543534365", customer: customer, orderItems: orderItems, orderDate: Date(), delivery: delivery, notes: "", allergies: "", isDelivered: false, isPaid: false)
        
        orderManager.addOrder(order: order)
        let retreivedOrder = orderManager.getOrderFromID(forOrderID: order.orderID)

        XCTAssertTrue(retreivedOrder.orderID == order.orderID, "Orders id's should be equal")
    }

    func testUpdatePaymentStatus() {
        let orderManager = TestOrderManager()
        let customer = Customer(name: "Test User", phoneNumber: "1234567890")
        let delivery = Delivery(address: "", cost: 0)
        let item = InventoryItem(itemID: "123", name: "cake", itemPrice: 120, itemQuantity: 20, size: "20 cm", AdditionDate: Date(), itemNotes: "Dairy")
        let orderItems = [OrderItem(inventoryItem: item, quantity: 1, price: item.itemPrice)]
        let order = Order(orderID: "123543534365", customer: customer, orderItems: orderItems, orderDate: Date(), delivery: delivery, notes: "", allergies: "", isDelivered: false, isPaid: false)
        
        orderManager.addOrder(order: order)

//        order.isPaid = true
        orderManager.updatePaymentStatus(orderID: order.orderID, isPaid: true)
//        orderManager.updateOrder(order: order)
        
        let retreivedOrder = orderManager.getOrderFromID(forOrderID: order.orderID)

        XCTAssertTrue(retreivedOrder.isPaid, "Order's payment status should be updated")
    }
    
    func testUpdateOrder() {
        let orderManager = TestOrderManager()
        let customer = Customer(name: "Test User", phoneNumber: "1234567890")
        let delivery = Delivery(address: "", cost: 0)
        let item = InventoryItem(itemID: "123", name: "cake", itemPrice: 120, itemQuantity: 20, size: "20 cm", AdditionDate: Date(), itemNotes: "Dairy")
        let orderItems = [OrderItem(inventoryItem: item, quantity: 1, price: item.itemPrice)]
        var order = Order(orderID: "123543534365", customer: customer, orderItems: orderItems, orderDate: Date(), delivery: delivery, notes: "", allergies: "", isDelivered: false, isPaid: false)
        
        orderManager.addOrder(order: order)

        order.isPaid = true
        orderManager.updateOrder(order: order)
        
        let retreivedOrder = orderManager.getOrderFromID(forOrderID: order.orderID)

        XCTAssertTrue(retreivedOrder.isPaid, "Order's payment status should be updated")
    }


}

