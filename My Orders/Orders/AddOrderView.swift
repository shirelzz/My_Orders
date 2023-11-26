//
//  AddOrderView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct AddOrderView: View {
    
    @State private var customer = Customer(name: "", phoneNumber: Int("") ?? 0)
    
    @State private var DessertName = ""
    @State private var DessertQuantity = 1
    @State private var DessertPrice = 0
    @State private var isAddingDessert = false
    @State private var Desserts: [Dessert] = []
    
    @State private var delivery = "No"
    @State private var deliveryAddress = ""
    //    @State private var deliveryCost = Double("")
    @State private var selectedDeliveryCost = 10
    let deliveryCosts = [0, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100]
    
    
    @State private var pickupDateTime = Date()
    
    @State private var allergies = "No"
    @State private var allergies_details = ""
    
    @State private var notes = ""
    
    @ObservedObject var orderManager: OrderManager
    @Environment(\.presentationMode) var presentationMode
    
    
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
            
            Section(header: Text("Dessert Selection")) {
                
                Button(action: {
                    self.isAddingDessert.toggle()
                    if !self.isAddingDessert {
                        if !self.DessertName.isEmpty {
                            self.Desserts.append(Dessert(
                                dessertName: self.DessertName,
                                quantity: self.DessertQuantity,
                                price: Double(self.DessertPrice)))
                            self.DessertName = ""
                            self.DessertQuantity = 1
                            self.DessertPrice = 0
                        }
                    }
                }) {
                    Text(self.isAddingDessert ? "Add" : "Add Dessert")
                }
                if isAddingDessert {
                    TextField("Dessert", text: $DessertName)
                    Stepper("Quantity: \(DessertQuantity)", value: $DessertQuantity, in: 1...100)
                    TextField("Price: \(DessertPrice)", value: $DessertPrice, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
                
                ForEach(Desserts.indices, id: \.self) { index in
                    HStack {
                        Text("\(self.Desserts[index].dessertName) (Quantity: \(self.Desserts[index].quantity))")
                        Spacer()
                        
                        Button(action: {
                            // Handle deletion action
                            self.Desserts.remove(at: index)
                        }) {
                            Text("Delete")
                                .foregroundColor(.red)
                        }
                    }
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
                        //                        deliveryCost = 0.0
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
                    
                    let newOrder = DessertOrder(
                        
                        orderID: UUID().uuidString, // Generates a unique ID for the order
                        customer: customer,
                        desserts: Desserts,
                        orderDate: pickupDateTime,
                        delivery: Delivery(address: deliveryAddress, cost: Double(selectedDeliveryCost)),
                        notes: notes,
                        allergies: allergies_details,
                        isCompleted: false,
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
