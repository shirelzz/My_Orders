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
    @State private var newPrice = 0.0
    @State private var newQuantity = 0
    @State private var additionDate = Date()
    @State private var newNotes = ""
    @State private var refreshView = false

    
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        
        NavigationView {
            
            Form {
                
                Section(header: Text("Item Information")) {
                    
                    TextField("Name", text: $newName)

                    TextField("Price", text: Binding<String>(
                        get: { String(newPrice) },
                        set: { if let newValue = Double($0) { newPrice = newValue} }
                    ))
                    .keyboardType(.numberPad)
                    
                    TextField("Quantity", text: Binding<String>(
                        get: { String(newQuantity) },
                        set: { if let newValue = Int($0) { newQuantity = newValue} }
                    ))
                    .keyboardType(.numberPad)
                    
//                    TextField("Catalog Number", text: $newCatalogNumber)

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
                        
                        let newItem = InventoryItem(
                            
                            id: UUID(),
                            name: newName,
                            itemPrice: newPrice,
                            itemQuantity: newQuantity,
                            AdditionDate: additionDate,
                            itemNotes: newNotes
//                            catalogNumber: newCatalogNumber

                        )
                        
//                        withAnimation{
//                            // Add the new order to the OrderManager
                            inventoryManager.addItem(item: newItem)
//                        }
                        
                        // Save items to UserDefaults
                        if let encodedData = try? JSONEncoder().encode(inventoryManager.items) {
                            UserDefaults.standard.set(encodedData, forKey: "items")
                        }
                        
//                        refreshView.toggle()

                        
                        // Clear the form or navigate to a different view as needed
                        // For example, you can navigate back to the previous view:
                        presentationMode.wrappedValue.dismiss()
                        
                    }) {
                        Text("Add Item")
                    }
                }
                
            }
            .navigationBarTitle("New Item")
        }
                
            }

        }
     

#Preview {
    AddItemView(inventoryManager: InventoryManager.shared)
}
