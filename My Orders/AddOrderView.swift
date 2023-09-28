//
//  AddOrderView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct AddOrderView: View {
    
    @State private var customer = Customer(name: "", phoneNumber: 0)
    
    @State private var DessertName = ""
    @State private var DessertQuantity = 1
    @State private var DessertPrice = 0
    @State private var isAddingDessert = false
    @State private var Desserts: [Dessert] = []
    
    @State private var delivery = "No"
    @State private var delivery_details = ""
    
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
            
            Section(header: Text("Dessert Selection")) {
                
                Button(action: {
                    self.isAddingDessert.toggle()
                    if !self.isAddingDessert {
                        if !self.DessertName.isEmpty {
                            self.Desserts.append(Dessert(dessertName: self.DessertName, quantity: self.DessertQuantity, price: Double(self.DessertPrice)))
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
                    Stepper("Quantity: \(DessertQuantity)", value: $DessertQuantity, in: 1...10)
                    TextField("Price", value: $DessertPrice, formatter: NumberFormatter())
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
                
            }
            
            Section(header: Text("More Information")) {
                
                Picker("Delivery", selection: $delivery) {
                    Text("No").tag("No")
                    Text("Yes").tag("Yes")
                }
                .onChange(of: delivery) { newValue in
                    if newValue == "Yes" {
                        delivery_details = ""
                    }
//                    else {
//                        delivery_details = ""
//                    }
                }

                if delivery == "Yes" {
                        TextEditor(text: $delivery_details)
                            .frame(height: 50)
                }
                
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
            
            //            Section {
            //                Button(action: {
            //                    OrderManager.shared.addOrder()
            //                }) {
            //                    ext("Add Order")
            //                    }
            //            }
            
        }
        .navigationBarTitle("New Order")
    }
}
