//
//  EditOrderView.swift
//  My Orders
//
//  Created by שיראל זכריה on 12/12/2023.
//

import SwiftUI

struct EditOrderView: View {
    
    @ObservedObject var orderManager: OrderManager
    @ObservedObject var inventoryManager: InventoryManager

    @Binding var order: Order
    @State var editedOrder: Order
    @State var showDeleteConfirmation = false
    
    @State private var newDessertQuantity = ""
    @State private var addedDesserts: [Dessert] = []
    @State private var deletedDesserts: [Dessert] = []
    
    @State private var isAddItemViewPresented = false
    @State private var selectedInventoryItem: InventoryItem? = nil
    @State private var selectedInventoryItemIndex = 0
    @State private var searchQuery = ""
    @State private var filteredItems: [InventoryItem] = []
    @State private var isQuantityValid = true
    @Environment(\.presentationMode) var presentationMode


    var body: some View {
        
        NavigationView {
                    Form {
                        
                        Section(header: Text("Order Information")) {
                            DatePicker("Order Date", selection: $editedOrder.orderDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                        }
                        
                        Section(header: Text("Order Details")) {
//                            List {
                                ForEach(0..<editedOrder.desserts.count, id: \.self) { index in
                                    DessertEditRow(dessert: $editedOrder.desserts[index])
                                }
                                .onDelete { indices in
                                            deleteDesserts(at: indices)
                                        }
//                            }
                            HStack{
                                // Calculate and display the total price
                                let totalPrice = editedOrder.desserts.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
                                
                                Text("Total Price: $")
                                Text("\(totalPrice, specifier: "%.2f")")
                            }
                        }
                        
                        Section(header: Text("Add Dessert")) {
                            TextField("Search for item", text: $searchQuery)
                                .padding()
                                .onChange(of: searchQuery) { value in
                                    filteredItems = inventoryManager.items.filter { $0.name.lowercased().contains(value.lowercased()) }
                                    
                                    // Set selectedInventoryItem to the first item in filteredItems if available
                                    if let firstItem = filteredItems.first {
                                        selectedInventoryItem = firstItem
                                    }
                                }
                            
                            
                            if filteredItems.isEmpty {
                                    Button(action: {
                                        isAddItemViewPresented = true
                                    }) {
                                        Text("Create new item")
                                    }
                                    .sheet(isPresented: $isAddItemViewPresented) {
                                        NavigationView{
                                            AddItemView(inventoryManager: inventoryManager)
                                        }
                                    }
                                }
                            else {
                                    Picker("item", selection: $selectedInventoryItemIndex) {
                                        ForEach( filteredItems.indices, id: \.self) { index in
                                            let item = filteredItems[index]
                                            let displayText = "\(item.name) , Q: \(item.itemQuantity), Price: $\(item.itemPrice)"
                                            
                                            Text(displayText)
                                                .tag(index)
                                        }
                                    }
                                    .onChange(of: selectedInventoryItemIndex) { newIndex in
                                        // Set selectedInventoryItem to the item at the selected index
                                        selectedInventoryItem = filteredItems[newIndex]
                                    }
                                    .pickerStyle(.inline)
                                    .labelsHidden()
                                
                                TextField("Quantity", text: $newDessertQuantity)
                                    .keyboardType(.numberPad)
                                    .onSubmit {
                                        validateQuantity()
                                    }

                                            if !isQuantityValid {
                                                Text("Please enter a valid quantity.")
                                                    .foregroundColor(.red)
                                            }
                                
//                                TextField("Quantity", text: Binding<String>(
//                                    get: { String(newDessertQuantity) },
//                                    set: { if let newValue = Int($0) { newDessertQuantity = newValue } }
//                                ))
//                                .keyboardType(.numberPad)
                                

                                
                                Button("Add New Dessert") {
                                    addDessert()
                                }
                                .disabled(!isQuantityValid)

                                }
                           
                                        }
                        
                        Section(header: Text("Additional Details")) {
                            TextField("Allergies", text: $editedOrder.allergies)
                            TextField("Delivery", text: $editedOrder.delivery.address)
                            TextField("Notes", text: $editedOrder.notes)
                        }
                        
                    }
                    .navigationBarTitle("Edit Order")
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            // Dismiss the sheet without saving changes
                            presentationMode.wrappedValue.dismiss()
                        },
                        trailing: HStack {
                            
                            Button("Save") {
                                // Save the changes and dismiss the sheet
                                order = editedOrder
                                orderManager.updateOrder(order: order)
                                
                                for dessert in addedDesserts {
                                        // Update the quantity of the selected inventory item
                                        if let selectedItem = inventoryManager.items.first(where: { $0.id == dessert.inventoryItem.id }) {
                                            inventoryManager.updateQuantity(item: selectedItem,
                                                                            newQuantity: selectedItem.itemQuantity - dessert.quantity)
                                        }
                                    }
                                
                                for dessert in deletedDesserts {
                                        // Update the quantity of the selected inventory item
                                        if let selectedItem = inventoryManager.items.first(where: { $0.id == dessert.inventoryItem.id }) {
                                            inventoryManager.updateQuantity(item: selectedItem,
                                                                            newQuantity: selectedItem.itemQuantity + dessert.quantity)
                                        }
                                    }
                                
                                
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    )
                }
        .onChange(of: newDessertQuantity) { _ in
                validateQuantity()
            }
    }
    
    private func validateQuantity() {
        isQuantityValid = Int(newDessertQuantity) == nil && Int(newDessertQuantity) ?? 0 > 0
    }
    
    private func addDessert() {
           // Check if a valid inventory item is selected
           guard let selectedInventoryItem = selectedInventoryItem else { return }

           // Create a new dessert with the selected inventory item and quantity
           let newDessert = Dessert(
               inventoryItem: selectedInventoryItem,
               quantity: Int(newDessertQuantity) ?? 0,
               price: selectedInventoryItem.itemPrice
           )

           // Add the new dessert to the edited order
           editedOrder.desserts.append(newDessert)
           addedDesserts.append(newDessert)
       }
    
    private func deleteDesserts(at indices: IndexSet) {
        let deletedDessertsBatch = indices.compactMap { index in
               return editedOrder.desserts[index]
        }
        
        editedOrder.desserts.remove(atOffsets: indices)
        addedDesserts.remove(atOffsets: indices)
        deletedDesserts.append(contentsOf: deletedDessertsBatch)
    }

}

struct DessertEditRow: View {
    
    @Binding var dessert: Dessert

    var body: some View {
        VStack(alignment: .leading) {
            Text("Dessert: \(dessert.inventoryItem.name)")
            
            HStack {
                Text("Quantity:")
                TextField("Enter Quantity", value: $dessert.quantity, formatter: NumberFormatter())
                    .textFieldStyle(.automatic)
            }
            
            HStack {
                Text("Price:")
                TextField("Enter Price", value: $dessert.price, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding()
    }
}

//#Preview {
//    EditOrderView(orderManager: OrderManager., order: <#Binding<Order>#>, editedOrder: <#Order#>)
//}
