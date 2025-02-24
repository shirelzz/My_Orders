//
//  EditItemView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI


struct EditItemView: View {
    
    @ObservedObject var inventoryManager: InventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var item: InventoryItem
    
    @State var name: String
    @State var price: Double
    @State var quantity: Int
    @State var size: String
    @State var notes: String
    
    @State private var isQuantityValid = true
    
    @State private var foodTags: [String] = ["Dairy", "Non-Dairy", "Vegan", "Vegetarian", "Gluten-Free"]
    @State private var selectedTags: [String] = []
    
    var body: some View {
        
        NavigationStack {
            Form {
                
                Section(header: Text("Change Name") ) {
                    TextField("Name", text: $name)
                        .padding(.vertical)
                        .frame(height: 30)
                }
                
                Section(header: Text("Change Price") ) {
                    TextField("Price", value: $price, formatter: NumberFormatter())
                        .padding(.vertical)
                        .frame(height: 30)
                }
                
                Section(header: Text("Change Quantity") ) {
                    TextField("Quantity", value: $quantity, formatter: NumberFormatter())
                        .padding(.vertical)
                        .frame(height: 30)
                        .onChange(of: quantity) { _ in
                            validateQuantity()
                        }

                    if !isQuantityValid {
                        Text("Please enter a valid quantity.")
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Change Size") ) {
                    TextField("Size", text: $size)
                        .padding(.vertical)
                        .frame(height: 30)
                }
                
                Section(header: Text("Change Notes") ) {
                    TextField("Notes", text: $notes)
                        .padding(.vertical)
                        .frame(height: 40)
                }
                
                Section(header: Text("Tags")) {
//                    if VendorManager.shared.vendor.vendorType == .food {
                        
                        ForEach(foodTags, id: \.self) { tag in
                            CheckboxToggle(isOn: $selectedTags, tag: tag)
                                .toggleStyle(iOSCheckboxToggleStyle())
                                .padding(.vertical, 5)
                        }
//                    }

                }
            }
            .navigationBarTitle("Edit Item")
            .padding(.top)
            .onAppear {
                selectedTags = item.tags ?? []
            }
            
            Button("Save Changes") {
//                if let selectedItem = item {
//                    inventoryManager.editItem(item: selectedItem, newName: name, newPrice: price, newQuantity: quantity, newSize: size, newNotes: notes, newTags: selectedTags)
//                }

                // await
                inventoryManager.editItem(item: item, newName: name, newPrice: price, newQuantity: quantity, newSize: size, newNotes: notes, newTags: selectedTags)
                
                presentationMode.wrappedValue.dismiss()

            }
            .padding()
            .cornerRadius(10)
            .buttonStyle(.borderedProminent)
            .disabled(!isQuantityValid)

        }
    }
    
    private func validateQuantity() {
        isQuantityValid = Int(quantity) > 0
    }
}
