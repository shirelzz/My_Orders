//
//  AddOrderView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct AddOrderView: View {
    @State private var client = Client(name: "", phoneNumber: "")
    @State private var DessertName = ""
    @State private var DessertQuantity = 1
    @State private var DessertPrice = 0
    @State private var quantity = 1
    @State private var allergies = ""
    @State private var notes = ""
    @State private var isAddingDessert = false
    @State private var Desserts: [Dessert] = []
    
    
    var body: some View {
        
        Form {
            
            Section(header: Text("Client Information")) {
                
                TextField("Client Name", text: $client.name)
                TextField("Phone Number", text: $client.phoneNumber)

            }
            
            Section(header: Text("Dessert Selection")) {
                
                Button(action: {
                    self.isAddingDessert.toggle()
                    if !self.isAddingDessert {
                        if !self.DessertName.isEmpty {
                            self.Desserts.append(Dessert(name: self.DessertName, quantity: self.DessertQuantity, price: self.DessertPrice))
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
                        Text("\(self.Desserts[index].name) (Quantity: \(self.Desserts[index].quantity))")
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
                
                Picker("Allergies", selection: $allergies) {
                    Text("No").tag("No")
                    Text("Yes").tag("Yes")
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100) // Adjust the height as needed
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
