//
//  AddOrderView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct AddOrderView: View {
    
    // to dos:
    // 1. cant pick a quantity greater than available
    
    @ObservedObject var orderManager: OrderManager
    @ObservedObject var inventoryManager: InventoryManager
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var customer = Customer(name: "", phoneNumber: Int("") ?? 0)
    
    //    @State private var inventoryItem = InventoryItem(name: "", itemPrice: 0.0, itemQuantity: 0, itemNotes: "" , catalogNumber: <#T##String#>)
    // or array og all items
    
    //    @State private var DessertName = ""
    //    @State private var selectedInventoryItem: InventoryItem?
    @State private var selectedInventoryItem: InventoryItem? = nil
    @State private var selectedInventoryItemIndex = 0
    
    @State private var searchQuery = ""
    @State private var filteredItems: [InventoryItem] = []
    
    @State private var DessertQuantity = 1
    @State private var DessertPrice = 0
    @State private var isAddingDessert = false
    
    @State private var Desserts: [Dessert] = []
    
    
    
    @State private var delivery = "No"
    @State private var deliveryAddress = ""
    @State private var selectedDeliveryCost = 0
    let deliveryCosts = [0, 10, 15, 20, 25, 30, 40, 50, 60]
    
    
    @State private var pickupDateTime = Date()
    
    @State private var allergies = "No"
    @State private var allergies_details = ""
    
    @State private var notes = ""
    
    
    var body: some View {
        
        Form {
            
            Section(header: Text("Customer Information")) {
                
                TextField("Customer Name", text: $customer.name)
                
                TextField("Phone Number", text: Binding<String>(
                    get: { String(customer.phoneNumber) },
                    set: { if let newValue = Int($0) { customer.phoneNumber = newValue } }
                ))
                .keyboardType(.numberPad)
                
            }
            
            
            Section(header: Text("Items Selection")) {
                TextField("Search for item...", text: $searchQuery)
                    .padding()
                    .onChange(of: searchQuery) { value in
                        filteredItems = inventoryManager.items.filter { $0.name.lowercased().contains(value.lowercased()) }
                        
                        // Set selectedInventoryItem to the first item in filteredItems if available
                        if let firstItem = filteredItems.first {
                            selectedInventoryItem = firstItem
                        }
                    }
                
                if !filteredItems.isEmpty {
                    Picker("Item", selection: $selectedInventoryItemIndex) {
                        ForEach(filteredItems.indices, id: \.self) { index in
                            let item = filteredItems[index]
                            let displayText = "\(item.name) , Q: \(item.itemQuantity), Price: ₪\(item.itemPrice)"
                            
                            Text(displayText)
                                .tag(index)
                        }
                    }
                    .onChange(of: selectedInventoryItemIndex) { newIndex in
                        // Set selectedInventoryItem to the item at the selected index
                        selectedInventoryItem = filteredItems[newIndex]
                    }
                }
                
                Stepper("Quantity: \(DessertQuantity)", value: $DessertQuantity, in: 1...100)
                
                Button(action: {
                    
                    if let selectedItem = selectedInventoryItem {
                            let dessert = Dessert(
                                inventoryItem: selectedItem,
                                quantity: DessertQuantity,
                                price: selectedItem.itemPrice
                            )
                            // editItem(item: InventoryItem, newName: String, newPrice: Double, newQuantity: Int, newNotes: String) {
                            // Deduct the selected quantity from the item's quantity in the InventoryManager
                            inventoryManager.editItem(
                                item: selectedItem,
                                newName: selectedItem.name,
                                newPrice: selectedItem.itemPrice,
                                newQuantity: selectedItem.itemQuantity - DessertQuantity,
                                newNotes: selectedItem.itemNotes
                            )
                            
                            // Append the dessert to the order
                            Desserts.append(dessert)
                        }
                    
                }) {
                    Text("Add Dessert")
                }
                
                // Calculate and display the total price
                let totalPrice = Desserts.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
                Text("Total Price: ₪\(totalPrice, specifier: "%.2f")")
            }
            
            
            
            
            Section(header: Text("More Information")) {
                
                Picker("Delivery", selection: $delivery) {
                    Text("No").tag("No")
                    Text("Yes").tag("Yes")
                }
                .onChange(of: delivery) { newValue in
                    if newValue == "Yes" {
                        deliveryAddress = ""
                    }
                }
                
                if delivery == "Yes" {
                    TextEditor(text: $deliveryAddress)
                        .frame(height: 50)
                    
                    Picker("Delivery cost: ₪", selection: $selectedDeliveryCost) {
                        ForEach(deliveryCosts, id: \.self) { cost in
                            Text("₪\(cost)").tag(cost)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                    
                }
                
                DatePicker("Pickup Date and Time", selection: $pickupDateTime, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                
                
                Picker("Allergies", selection: $allergies) {
                    Text("No").tag("No")
                    Text("Yes").tag("Yes")
                }
                .onChange(of: allergies) { newValue in
                    if newValue == "Yes" {
                        allergies_details = ""
                    }
                    else {
                        allergies_details = ""
                    }
                }
                
                if allergies == "Yes" {
                    TextEditor(text: $allergies_details)
                        .frame(height: 50)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                
                
            }
            
            Section {
                Button(action: {
                    
                    let newOrder = Order(
                        
                        orderID: UUID().uuidString, // Generates a unique ID for the order
                        customer: customer,
                        desserts: Desserts,
                        orderDate: pickupDateTime,
                        delivery: Delivery(address: deliveryAddress, cost: Double(selectedDeliveryCost)),
                        notes: notes,
                        allergies: allergies_details,
                        isCompleted: false,
                        isPaid: false,
                        receipt: nil
                        
                    )
                    
                    // Add the new order to the OrderManager
                    orderManager.addOrder(order: newOrder)
                    
                    // Save orders to UserDefaults
                    if let encodedData = try? JSONEncoder().encode(orderManager.orders) {
                        UserDefaults.standard.set(encodedData, forKey: "orders")
                    }
                    
                    // Clear the form or navigate to a different view as needed
                    // For example, you can navigate back to the previous view:
                    presentationMode.wrappedValue.dismiss()
                    
                }) {
                    Text("Add Order")
                }
            }
        }
        .navigationBarTitle("New Order")
    }
}
