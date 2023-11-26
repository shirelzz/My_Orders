//
//  EditItemView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI


struct EditItemView: View {
    
    @ObservedObject var viewModel = InventoryManager()

    @State var item: InventoryItem?
    @State var name: String
    @State var price: Int
    @State var quantity: Int
    @State var notes: String


    var body: some View {
        
        VStack(alignment: .leading, spacing: 10)
        {
            
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Price", value: $price, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Quantity", value: $quantity, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Notes", text: $notes)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Save Changes") {
                if let selectedItem = item {
                        viewModel.editItem(item: selectedItem, newName: name, newPrice: price, newQuantity: quantity, newNotes: notes)
                    }            }
            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .navigationBarTitle("Edit Item")
    }
}



//struct EditItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Assuming you have some state variables in your parent view
//        @State var isEditing = false
//        @State var itemName = "Example Item"
//        @State var itemPrice = 10.0
//
//        return EditItemView(viewModel: InventoryItemModel(), item: Binding<InventoryItem?>, name: <#T##Binding<String>#>, price: <#T##Binding<Double>#>, name: $itemName, price: $itemPrice) {
//            // Handle save action in your parent view
//            print("Save action")
//        }
//    }
//}
