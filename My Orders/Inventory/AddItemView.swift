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
    @State private var newQuantityString = ""
    @State private var newQuantity = 0
    @State private var newSize = ""
    @State private var additionDate = Date()
    @State private var newNotes = ""
    @State private var quantityError = false
    @State private var foodTags: [String] = ["Dairy", "Non-Dairy", "Vegan", "Vegetarian", "Gluten-Free"]
    @State private var selectedTags: [String] = []

    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        
        NavigationView {
            
            List {
                
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
                
                Section(header: Text("Tags")) {
                    if VendorManager.shared.vendor.vendorType == .food {
                        
                        ForEach(foodTags, id: \.self) { tag in
                            CheckboxToggle(isOn: $selectedTags, tag: tag)
                                .toggleStyle(iOSCheckboxToggleStyle())
                                .padding(.vertical, 5)
                        }
                    }

                }
                
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
                                itemNotes: newNotes,
                                tags: selectedTags
                            )
                            
                            inventoryManager.addItem(item: newItem)
                            
                            // Save items to UserDefaults
                            if let encodedData = try? JSONEncoder().encode(inventoryManager.items) {
                                UserDefaults.standard.set(encodedData, forKey: "items")
                            }

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

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {

            configuration.isOn.toggle()

        }, label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")

                configuration.label
            }
        })
    }
}

struct CheckboxToggle: View {
    @Binding var isOn: [String]
    let tag: String

    var body: some View {
        Toggle(isOn: Binding(
            get: { isOn.contains(tag) },
            set: { newValue in
                if newValue {
                    isOn.append(tag)
                } else {
                    isOn.removeAll { $0 == tag }
                }
            }
        )) {
            Text(tag)
                .foregroundStyle(.primary)
        }
    }
}

