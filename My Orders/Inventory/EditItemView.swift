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
    
    @State var item: InventoryItem?
    @State var name: String
    @State var price: Double
    @State var quantity: Int
    @State var size: String
    @State var notes: String
    
    @State private var isQuantityValid = true
    
    
    var body: some View {
        
        NavigationStack
        {
            Form
            {
                
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
//                        .onSubmit {
//                            validateQuantity()
//                        }
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
                
            }
            .navigationBarTitle("Edit Item")
            .padding(.top)
            
            Button("Save Changes") {
                if let selectedItem = item {
                    inventoryManager.editItem(item: selectedItem, newName: name, newPrice: price, newQuantity: quantity, newSize: size, newNotes: notes)
                }

                
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



struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        
        let itemName = "Cupcake"
        let itemPrice = 10.0
        let itemQuantity = 5
        
        EditItemView(inventoryManager: InventoryManager.shared, name: itemName, price: itemPrice, quantity: itemQuantity, size: "", notes: "")
    }
}
