//
//  AddOrderView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI
import Combine

struct AddOrderView: View {
    
    @ObservedObject var orderManager: OrderManager
    @ObservedObject var inventoryManager: InventoryManager
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var customer = Customer(name: "", phoneNumber: "")
    @State private var selectedInventoryItem: InventoryItem? = nil
    @State private var selectedInventoryItemIndex = 0

    @State private var searchQuery = ""
    @State private var filteredItems: [InventoryItem] = []
    
    @State private var orderItemQuantity = ""
    @State private var DessertPrice = 0
    @State private var isAddingDessert = false
    
    @State private var orderItems: [OrderItem] = []
    @State private var existedOrderItems: [OrderItem] = []
    @State private var deletedInventoryItem: InventoryItem? = nil
    
    @State private var delivery = "No"
    @State private var deliveryAddress = ""
    @State private var selectedDeliveryCost = 0
    let deliveryCosts = [0, 5, 10, 15, 20, 25, 30, 40, 50, 60]
    
    
    @State private var pickupDateTime = Date()
    
    @State private var allergies = "No"
    @State private var allergies_details = ""
    
    @State private var notes = ""
    @State private var isAddItemViewPresented = false
    @State private var isQuantityValid = true
    
    @State private var isItemDetailsPopoverPresented = false
    @State private var selectedItemForDetails: InventoryItem?
    @State private var showItemDetails = false
    
    var body: some View {
        
        Form {
            
            Section(header: Text("Customer Information")) {
                
                TextField("Customer Name", text: $customer.name)
                
                TextField("Phone Number", text: $customer.phoneNumber)
                    .keyboardType(.numberPad)
                    
            }
            
            
            Section(header: Text("Items Selection")) {
    
                HStack {
                    TextField("Search for item", text: $searchQuery)
                        .frame(height: 40)
                        .padding(.leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10.0)
                        .overlay(
                            HStack {
                                Spacer()
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                            }
                                .padding(.horizontal, 18)
                        )
                        .onChange(of: searchQuery) { value in
                            filteredItems = inventoryManager.items
                                .filter { $0.name.lowercased().contains(value.lowercased()) }
                                .sorted { $0.name < $1.name }
                            
                            // Set selectedInventoryItem to the first item in filteredItems if available
                            if let firstItem = filteredItems.first {
                                selectedInventoryItem = firstItem
                            }
                        }
                    
                    Spacer(minLength: 15)
                    
                        Button {
                            isAddItemViewPresented = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .tint(.accentColor)
                                .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
                        }
                        .foregroundColor(.accentColor) // Set desired text color
                        .tint(.clear)
                        .popover(isPresented: $isAddItemViewPresented) {
                            AddItemView(inventoryManager: inventoryManager)
                        }
                        .buttonStyle(.bordered)
                        .frame(width: 20, height: 20)
                        .padding(5)

                }

                if !searchQuery.isEmpty {

                        Picker("item", selection: $selectedInventoryItemIndex) {
                            ForEach( filteredItems.indices.sorted(by: { filteredItems[$0].name < filteredItems[$1].name }), id: \.self) { index in
                                let item = filteredItems[index]
                                
                                HStack{
                                    Text("\(item.name)").font(.system(size: 14))
                                    Text(",").font(.system(size: 14))
                                    Text("Q: \(item.itemQuantity)").font(.system(size: 14))
                                    Text(",").font(.system(size: 14))
                                    Text("Price:$\(item.itemPrice, specifier: "%.2f")").font(.system(size: 14))
                                }
                            }
                        }
                        .onChange(of: selectedInventoryItemIndex) { newIndex in
                            // Set selectedInventoryItem to the item at the selected index
                            print("---> newIndex: \(newIndex)")
                            selectedInventoryItem = filteredItems[newIndex]
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                    }
                
                TextField("Quantity", text: $orderItemQuantity)
                    .keyboardType(.numberPad)
                    .onChange(of: orderItemQuantity) { _ in
                            validateQuantity()
                    }

                if !isQuantityValid && orderItemQuantity != "" {
                    Text("Please enter a valid quantity.")
                        .foregroundColor(.red)
                }
                                
                Button(action: {
                    
                    // Check if a valid inventory item is selected
                        guard let selectedInventoryItem = selectedInventoryItem else { return }
                        
                        // Check if there is already a dessert with the same item
                        if let existingDessertIndex = orderItems.firstIndex(where: { $0.inventoryItem.itemID == selectedInventoryItem.itemID }) {
                            // Update the quantity of the existing dessert
                            orderItems[existingDessertIndex].quantity += Int(orderItemQuantity) ?? 0
                            
                            // Create a new dessert and add it to the addedDesserts so the item's quantity will be updated
                            let existDessert = OrderItem(
                                inventoryItem: selectedInventoryItem,
                                quantity: Int(orderItemQuantity) ?? 0,
                                price: selectedInventoryItem.itemPrice
                            )
                            existedOrderItems.append(existDessert)
                        }
                        else {
                            let dessert = OrderItem(
                                inventoryItem: selectedInventoryItem,
                                quantity: Int(orderItemQuantity) ?? 0,
                                price: selectedInventoryItem.itemPrice
                            )
                            
                            // Append the dessert to the order
                            orderItems.append(dessert)
                            
                            self.selectedInventoryItem = nil
                            searchQuery = ""
                            orderItemQuantity = ""
                        }
                    
                }){
                    Text("Add item to order")
                }
                .disabled(!isQuantityValid || selectedInventoryItem == nil || orderItemQuantity == "")
            }
            
            Section(header: Text("Added Items")){
                ForEach(orderItems.indices, id: \.self) { index in
                    HStack {
                        Text("\(orderItems[index].inventoryItem.name) (Quantity: \(orderItems[index].quantity))")
                        
                        Spacer()
                        
                        Button(action: {
                            // Get the selected dessert
                            let deletedDessert = orderItems[index]
                            
                            // Delete the dessert from the list
                            orderItems.remove(at: index)

                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }

                    }
                }
                
                HStack{
                    // Calculate and display the total price
                    let totalPrice = orderItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
                    
                    Text("Total Price: $")
                    Text("\(totalPrice, specifier: "%.2f")")
                }
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
                    TextField("Address" , text: $deliveryAddress)
                        .frame(height: 50)
                    
                    Picker("Delivery cost: $", selection: $selectedDeliveryCost) {
                        ForEach(deliveryCosts, id: \.self) { cost in
                            Text("$\(cost)").tag(cost)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                    
                }
                
                DatePicker("Pickup Date and Time",
                           selection: $pickupDateTime,
                           in: Date()...,
                           displayedComponents: [.date, .hourAndMinute])
                
                
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
                    TextField("Allergies", text: $allergies_details)
                        .frame(height: 50)
                }
                
                TextField("Notes", text: $notes)
                   .frame(height: 100)

                
            }
            
            Section {
                Button(action: {
                    
                    for dessert in orderItems {
                            // Update the quantity of the selected inventory item
                        if let selectedItem = inventoryManager.items.first(where: { $0.id == dessert.inventoryItem.itemID }) {
                            inventoryManager.updateQuantity(item: selectedItem,
                                                            newQuantity: selectedItem.itemQuantity - dessert.quantity)
                            }
                        }
                    
                    for dessert in existedOrderItems {
                            // Update the quantity of the selected inventory item
                        if let selectedItem = inventoryManager.items.first(where: { $0.id == dessert.inventoryItem.itemID }) {
                            inventoryManager.updateQuantity(item: selectedItem,
                                                            newQuantity: selectedItem.itemQuantity - dessert.quantity)
                            }
                        }
                    
                    let newOrder = Order(
                        
                        orderID: UUID().uuidString,
                        customer: customer,
                        orderItems: orderItems,
                        orderDate: pickupDateTime,
                        delivery: Delivery(address: deliveryAddress, cost: Double(selectedDeliveryCost)),
                        notes: notes,
                        allergies: allergies_details,
                        isDelivered: false,
                        isPaid: false
//                        discountAmount: amount,
//                        discountPercentage: percentage,
//                        discountType: selectedDiscountType,
//                        receipt: nil
                        
                    )
                    
                    // Add the new order to the OrderManager
                    orderManager.addOrder(order: newOrder)
                    
                    // Save orders to UserDefaults
                    if let encodedData = try? JSONEncoder().encode(orderManager.orders) {
                        UserDefaults.standard.set(encodedData, forKey: "orders")
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                    
                }) {
                    Text("Add Order")
                }
            }
        }
        .navigationBarTitle("New Order")
    }
    
    private func validateQuantity() {
        isQuantityValid =
        Int(orderItemQuantity) ?? 0 > 0 &&
        (Int(selectedInventoryItem?.itemQuantity ?? 0) - (Int(orderItemQuantity) ?? 0)) >= 0
        // Int(DessertQuantity) != nil &&
    }
}

#Preview {
    AddOrderView(orderManager: OrderManager.shared,
                 inventoryManager: InventoryManager.shared
                 
    )
}
