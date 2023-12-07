//
//  EditItemView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI


struct EditItemView: View {
    
    @ObservedObject var inventoryManager = InventoryManager()
    
    @State var item: InventoryItem?
    @State var name: String
    @State var price: Double
    @State var quantity: Int
    @State var notes: String
    
    
    var body: some View {
        
        NavigationStack
        {
            Form
            {
                
                Section(header: Text("Change Name") ) {
                    TextField("Name", text: $name)
                        .padding(.vertical)
                }
                
                Section(header: Text("Change Price") ) {
                    TextField("Price", value: $price, formatter: NumberFormatter())
                        .padding(.vertical)
                }
                
                Section(header: Text("Change Quantity") ) {
                    TextField("Quantity", value: $quantity, formatter: NumberFormatter())
                        .padding(.vertical)
                }
                
                Section(header: Text("Change Notes") ) {
                    TextField("Notes", text: $notes)
                        .padding(.vertical)
                }
                
            }
            .navigationBarTitle("Edit Item")
            .padding(.top)
            
            Button("Save Changes") {
                if let selectedItem = item {
                    inventoryManager.editItem(item: selectedItem, newName: name, newPrice: price, newQuantity: quantity, newNotes: notes)
                }
            }
            .padding()
            .cornerRadius(10)
            .buttonStyle(.borderedProminent)
        }
    }
}



struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        
        let itemName = "Cupcake"
        let itemPrice = 10.0
        let itemQuantity = 5
        
        EditItemView(name: itemName, price: itemPrice, quantity: itemQuantity, notes: "")
    }
}
