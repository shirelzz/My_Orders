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
    @State private var newQuantity = ""
    @State private var newSize = ""
    @State private var additionDate = Date()
    @State private var newNotes = ""
    @State private var refreshView = false

    
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        
        NavigationView {
            
            Form {
                
                Section(header: Text("Item Information")) {
                    
                    TextField("Name", text: $newName)

                    TextField("Price", text: $newPrice)
                    .keyboardType(.numberPad)
                    
                    TextField("Quantity", text: $newQuantity)
                    .keyboardType(.numberPad)
                    
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
                        
                        let newItem = InventoryItem(
                            
                            id: UUID(),
                            name: newName,
                            itemPrice: Double(newPrice) ?? 0.0,
                            itemQuantity: Int(newQuantity) ?? 0,
                            size: newSize,
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
