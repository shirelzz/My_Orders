//
//  OrderDetailsViewTests.swift
//  My OrdersTests
//
//  Created by שיראל זכריה on 20/11/2024.
//

import XCTest
import SwiftUI
@testable import My_Orders

final class OrderDetailsViewTests: XCTestCase {

//    // Test to ensure the view initializes with the correct state
//    func testInitialState() {
//        let order = Order(orderID: "123", customer: Customer(name: "John Doe", phoneNumber: "1234567890"), orderItems: [], orderDate: Date(), delivery: Delivery(address: "", cost: 0), notes: "", allergies: "", isDelivered: false, isPaid: false)
//        let orderManager = OrderManager()
//        let inventoryManager = InventoryManager()
//        
//        let view = OrderDetailsView(orderManager: orderManager, inventoryManager: inventoryManager, order: order)
//        
//        XCTAssertFalse(view.isEditing, "isEditing should be false initially")
//        XCTAssertFalse(view.showInfo, "showInfo should be false initially")
//        XCTAssertEqual(view.currency, "$", "Currency symbol should be initialized correctly")
//    }
//
//    // Test the copy button functionality
//    func testCopyOrderDetailsButton() {
//        let order = Order(orderID: "123", customer: Customer(name: "John Doe", phoneNumber: "1234567890"), orderItems: [
//            OrderItem(inventoryItem: InventoryItem(itemID: "1", name: "Test Item", itemPrice: 10.0, itemQuantity: 5, size: "Small", AdditionDate: Date(), itemNotes: "Note"), quantity: 2, price: 20.0)
//        ], orderDate: Date(), delivery: Delivery(address: "123 Test Street", cost: 5.0), notes: "Test Notes", allergies: "None", isDelivered: false, isPaid: false)
//        
//        let orderManager = OrderManager()
//        let inventoryManager = InventoryManager()
//        let view = OrderDetailsView(orderManager: orderManager, inventoryManager: inventoryManager, order: order)
//
//        // Simulate copy button action
//        UIPasteboard.general.string = nil
//        view.copyOrderDetails()
//        
//        XCTAssertNotNil(UIPasteboard.general.string, "Copied text should not be nil")
//        XCTAssertTrue(UIPasteboard.general.string!.contains("John Doe"), "Copied details should include customer name")
//        XCTAssertTrue(UIPasteboard.general.string!.contains("123 Test Street"), "Copied details should include delivery address")
//    }
//
//    // Test toggling isEditing
//    func testToggleEditingState() {
//        let order = Order(orderID: "123", customer: Customer(name: "John Doe", phoneNumber: "1234567890"), orderItems: [], orderDate: Date(), delivery: Delivery(address: "", cost: 0), notes: "", allergies: "", isDelivered: false, isPaid: false)
//        let orderManager = OrderManager()
//        let inventoryManager = InventoryManager()
//        
//        var view = OrderDetailsView(orderManager: orderManager, inventoryManager: inventoryManager, order: order)
//        
//        XCTAssertFalse(view.isEditing, "isEditing should initially be false")
//        
//        view.isEditing = true
//        XCTAssertTrue(view.isEditing, "isEditing should be true after being toggled")
//    }
//
//    // Test showing modals
//    func testShowInfoModal() {
//        let order = Order(orderID: "123", customer: Customer(name: "John Doe", phoneNumber: "1234567890"), orderItems: [], orderDate: Date(), delivery: Delivery(address: "", cost: 0), notes: "", allergies: "", isDelivered: false, isPaid: false)
//        let orderManager = OrderManager()
//        let inventoryManager = InventoryManager()
//        
//        var view = OrderDetailsView(orderManager: orderManager, inventoryManager: inventoryManager, order: order)
//        
//        XCTAssertFalse(view.showInfo, "showInfo should initially be false")
//        
//        view.showInfo = true
//        XCTAssertTrue(view.showInfo, "showInfo should be true after being toggled")
//    }
}

