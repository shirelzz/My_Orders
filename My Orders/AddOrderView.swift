//
//  AddOrderView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct AddOrderView: View {
    @State private var customerName = ""
    @State private var selectedDessert = 0 // Index of selected dessert
    @State private var quantity = 1
    
    let desserts = ["Chocolate Cake", "Apple Pie", "Ice Cream"] // Replace with your dessert options
    
    var body: some View {
        Form {
            Section(header: Text("Customer Information")) {
                TextField("Customer Name", text: $customerName)
            }
            
            Section(header: Text("Dessert Selection")) {
                Picker("Select Dessert", selection: $selectedDessert) {
                    ForEach(0..<desserts.count, id: \.self) {
                        Text(self.desserts[$0])
                    }
                }
                Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10)
            }
            
            Section {
                Button(action: {
                    // Action to add the order with the entered data
                    // You can use OrderManager.shared.addOrder() here
                }) {
                    Text("Add Order")
                }
            }
        }
        .navigationBarTitle("New Order")
    }
}
