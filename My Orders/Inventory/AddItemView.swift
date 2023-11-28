//
//  AddItemView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI

struct AddItemView: View {
    
    @ObservedObject var inventoryManager = InventoryManager()

    // State variables for new item input
    @State private var newName = ""
    @State private var newCatalogNumber = ""
    @State private var newPrice = 0.0
    @State private var newQuantity = 0
    @State private var newNotes = ""
    
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
                    
                    TextField("Notes", text: $newNotes)
                    
                    TextField("Catalog Number", text: $newCatalogNumber)



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
                            itemNotes: newNotes,
                            catalogNumber: newCatalogNumber

                        )
                        
                        withAnimation{
                            // Add the new order to the OrderManager
                            inventoryManager.addItem(item: newItem)
                        }
                        
                        // Save orders to UserDefaults
                        if let encodedData = try? JSONEncoder().encode(inventoryManager.items) {
                            UserDefaults.standard.set(encodedData, forKey: "items")
                        }
                        
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
    
//    func saveItem() {
//            viewModel.addItem(item: item)
//            // Optionally, you can navigate back to the previous view or perform any other action after saving.
//        }
        }
     

#Preview {
    AddItemView()
}
