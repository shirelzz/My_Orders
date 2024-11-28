//
//  AddItemView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI

struct AddItemView: View {
    
    @ObservedObject var inventoryManager: InventoryManager
    @ObservedObject var tagManager: TagManager
    @State var knownName: String?
    
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
    
    @State private var otherBusinessesTags: [String] = []
    @State private var selectedTags: [String] = []
    @State private var isAddingTag = false
    @State private var newTagText = ""

    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        
        NavigationView {
            
            List {
                
                Section(header: Text("Item Information")) {
                    
                    TextField("Name", text: $newName)
                        .onAppear(perform: {
                            newName = knownName ?? ""
                        })
                    
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
                        
                    ForEach(tagManager.tags, id: \.self) { tag in
                        CheckboxToggle(isOn: $selectedTags, tag: tag)
                            .toggleStyle(iOSCheckboxToggleStyle())
                            .padding(.vertical, 5)
                    }
                    
                    if isAddingTag {

                        HStack {
                            TextField("Enter new tag", text: $newTagText, onCommit: {
                                // Save the new tag when user presses return/enter
                                if !newTagText.isEmpty {
//                                    selectedTags.append(newTagText)
                                    tagManager.addTag(newTagText)
                                    newTagText = ""
                                    isAddingTag = false
                                }
                            })
                            .onAppear(perform: {
                                newTagText = ""
                            })
                            //                        .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            
//                            Button(action: {
//                                if !newTagText.isEmpty {
//                                    selectedTags.append(newTagText)
//                                    newTagText = ""
//                                    isAddingTag = false
//                                }
//                            }) {
//                                Text("Add")
//                            }
                        }
                        
                    } else {
                        
                        Button(action: {
                            isAddingTag = true
                        }) {
                            Image(systemName: "plus.square.fill")
                                .font(.system(size: 18))
                            
                        }
                    }
                    
                }
                
//                Section {
//                    Button(action: {
//                        
//                        if newQuantity > 0 {
//                            
//                            let newItem = InventoryItem(
//                                
//                                itemID: UUID().uuidString,
//                                name: newName,
//                                itemPrice: Double(newPrice) ?? 0.0,
//                                itemQuantity: newQuantity,
//                                size: newSize,
//                                AdditionDate: additionDate,
//                                itemNotes: newNotes,
//                                tags: selectedTags
//                            )
//                            
//                            inventoryManager.addItem(item: newItem)
//                            
//                            // Save items to UserDefaults
//                            if let encodedData = try? JSONEncoder().encode(inventoryManager.items) {
//                                UserDefaults.standard.set(encodedData, forKey: "items")
//                            }
//                            
//                            presentationMode.wrappedValue.dismiss()
//                        }
//                        else{
//                            quantityError = true
//                        }
//                        
//                    }) {
//                        Text("Add Item")
//                    }
//                    .disabled(quantityError)
//                    .buttonStyle(.borderless)
//                }
                
            }
            .navigationBarTitle("New Item")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
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
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        
    }
    
}
     

#Preview {
    AddItemView(inventoryManager: InventoryManager.shared, tagManager: TagManager.shared)
}
