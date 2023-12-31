//
//  AddItemView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI

struct AddItemView: View {
    
    @ObservedObject var inventoryManager: InventoryManager

    // State variables for new item input
    @State private var newName = ""
    @State private var newCatalogNumber = ""
    @State private var newPrice = ""
//    @State private var newQuantity = ""
    @State private var newQuantityString = ""
    @State private var newQuantity = 0
    @State private var newSize = ""
    @State private var additionDate = Date()
    @State private var newNotes = ""
//    @State private var refreshView = false
    @State private var quantityError = false


    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        
        NavigationView {
            
            Form {
                
                Section(header: Text("Item Information")) {
                    
                    TextField("Name", text: $newName)

                    TextField("Price", text: $newPrice)
                    .keyboardType(.decimalPad)
                    
                    TextField("Quantity", text: $newQuantityString)
                    .keyboardType(.numberPad)
                    .onChange(of: newQuantityString) { newValue in
                        if let quantity = Int(newValue), quantity > 0 {
                            newQuantity = quantity
                            quantityError = false
                        } else {
                            newQuantity = 0
                            quantityError = true
                        }
                    }
                    
                    if quantityError {
                        Text("Quantity is less or equal to zero.")
                            .foregroundColor(.red)
                    }
                    
                    TextField("Size", text: $newSize)

                    DatePicker("Date Added",
                               selection: $additionDate,
                               in: Date()...,
                               displayedComponents: [.date])
                    
                    TextField("Notes", text: $newNotes)


                }
                
//                Section {
//                                    Button("Save Item") {
//                                        saveItem()
//                                    }
//                                }
                
                Section {
                    Button(action: {
                        
                        if newQuantity > 0 {
                            
                            let newItem = InventoryItem(
                                
                                itemID: UUID().uuidString,
                                name: newName,
                                itemPrice: Double(newPrice) ?? 0.0,
                                itemQuantity: newQuantity,
                                size: newSize,
                                AdditionDate: additionDate,
                                itemNotes: newNotes
                            )
                            
                            inventoryManager.addItem(item: newItem)
                            
                            // Save items to UserDefaults
                            if let encodedData = try? JSONEncoder().encode(inventoryManager.items) {
                                UserDefaults.standard.set(encodedData, forKey: "items")
                            }
                            
                            // Clear the form or navigate to a different view as needed
                            // For example, you can navigate back to the previous view:
                            presentationMode.wrappedValue.dismiss()
                        }
                        else{
                            quantityError = true
                        }
                        
                    }) {
                        Text("Add Item")
                    }
                    .disabled(quantityError)
                }
                
            }
            .navigationBarTitle("New Item")
        }
                
            }

        }
     

#Preview {
    AddItemView(inventoryManager: InventoryManager.shared)
}
