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
    @State var showDeleteOrderAlert = false
    
    @State private var newDessertQuantity = ""
    @State private var addedOrderItems: [OrderItem] = []
    @State private var deletedOrderItems: [OrderItem] = []
    
    @State private var isAddItemViewPresented = false
    @State private var selectedInventoryItem: InventoryItem? = nil
    @State private var selectedInventoryItemIndex = 0
    @State private var searchQuery = ""
    @State private var filteredItems: [InventoryItem] = []
    @State private var isQuantityValid = true
    @State private var navigateToContentView = false

    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        
        NavigationView {
            Form {
                
                Section(header: Text("Order Information")) {
                    DatePicker("Order Date", selection: $editedOrder.orderDate, in: Date(timeIntervalSince1970: 0)..., displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Order Details")) {
                    //                            List {
                    ForEach(0..<editedOrder.orderItems.count, id: \.self) { index in
                        DessertEditRow(dessert: $editedOrder.orderItems[index])
                    }
                    .onDelete { indices in
                        deleteOrderItems(at: indices)
                    }
                    //                            }
                    HStack{
                        // Calculate and display the total price
                        let totalPrice = editedOrder.orderItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
                        
                        Text("Total Price: $")
                        Text("\(totalPrice, specifier: "%.2f")")
                    }
                }
                
                Section(header: Text("Add Item")) {
                    TextField("Search for item", text: $searchQuery)
                        .padding()
                        .frame(height: 40)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10.0)
                        .overlay(
                            HStack {
                                Spacer()
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 18)
                        )
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
                        
                        Button("Add New Item") {
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
                
                Section{
                    Button("Delete") {
                        // Handle delete action
                        showDeleteOrderAlert = true
                    }
                    .tint(.red)
                    .alert(isPresented: $showDeleteOrderAlert) {
                        Alert(
                            title: Text("Confirm Deletion"),
                            message: Text("Are you sure you want to delete this order?"),
                            primaryButton: .destructive(
                                Text("Delete"),
                                action: {
                                    order = editedOrder
                                    
                                    if !order.isDelivered && !order.orderItems.isEmpty{
                                        print("---> entered 1st if")

                                        for orderItem in order.orderItems {
                                            // Update the quantity of the selected inventory item
                                            print("---> Updating quantity for order item: \(orderItem.inventoryItem.name)")

                                            if let selectedItem = inventoryManager.items.first(where: { $0.id == orderItem.inventoryItem.itemID }) {
                                                inventoryManager.updateQuantity(item: selectedItem,
                                                                                newQuantity: selectedItem.itemQuantity + orderItem.quantity)
                                                print("---> update 1")

                                            }
                                        }
                                        
                                    }
                                    
                                    if !addedOrderItems.isEmpty{
                                        print("---> entered 2nd if")

                                        for orderItem in addedOrderItems {
                                            // Update the quantity of the selected inventory item
                                            if let selectedItem = inventoryManager.items.first(where: { $0.id == orderItem.inventoryItem.itemID }) {
                                                inventoryManager.updateQuantity(item: selectedItem,
                                                                                newQuantity: selectedItem.itemQuantity - orderItem.quantity)
                                                print("---> update 2")
                                            }
                                        }
                                    }
                                    
                                    if !deletedOrderItems.isEmpty{
                                        print("---> entered 3rd if")

                                        for orderItem in deletedOrderItems {
                                            // Update the quantity of the selected inventory item
                                            if let selectedItem = inventoryManager.items.first(where: { $0.id == orderItem.inventoryItem.itemID }) {
                                                inventoryManager.updateQuantity(item: selectedItem,
                                                                                newQuantity: selectedItem.itemQuantity + orderItem.quantity)
                                                print("---> update 3")
                                            }
                                        }
                                    }
                                    
                                    deleteOrder(order: order)

                                    presentationMode.wrappedValue.dismiss()
                                }
                            ),
                            secondaryButton: .cancel(Text("Cancel"))
                        )
                    }
                    
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
                        
                        for orderItem in addedOrderItems {
                            // Update the quantity of the selected inventory item
                            if let selectedItem = inventoryManager.items.first(where: { $0.id == orderItem.inventoryItem.itemID }) {
                                inventoryManager.updateQuantity(item: selectedItem,
                                                                newQuantity: selectedItem.itemQuantity - orderItem.quantity)
                            }
                        }
                        
                        for orderItem in deletedOrderItems {
                            // Update the quantity of the selected inventory item
                            if let selectedItem = inventoryManager.items.first(where: { $0.id == orderItem.inventoryItem.itemID }) {
                                inventoryManager.updateQuantity(item: selectedItem,
                                                                newQuantity: selectedItem.itemQuantity + orderItem.quantity)
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
    
    private func dismiss(_ n: Int) {
        let rootViewController = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map {$0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter({ $0.isKeyWindow }).first?.rootViewController
        guard let rootViewController = rootViewController else { return }

        var leafFlound = false
        var viewStack: [UIViewController] = [rootViewController]
        while(!leafFlound) {
            if let presentedViewController = viewStack.last?.presentedViewController {
                viewStack.append(presentedViewController)
            } else {
                leafFlound = true
            }
        }
        let presentingViewController = viewStack[max(0, viewStack.count - n - 1)]
        presentingViewController.dismiss(animated: true)
    }
    
    private func validateQuantity() {
        isQuantityValid = Int(newDessertQuantity) != nil && Int(newDessertQuantity) ?? 0 > 0
    }
    
    private func addDessert() {
        
        // Check if a valid inventory item is selected
        guard let selectedInventoryItem = selectedInventoryItem else { return }
        
        // Check if there is already a dessert with the same item
        if let existingDessertIndex = editedOrder.orderItems.firstIndex(where: { $0.inventoryItem.itemID == selectedInventoryItem.itemID }) {
            // Update the quantity of the existing dessert
            editedOrder.orderItems[existingDessertIndex].quantity += Int(newDessertQuantity) ?? 0
            
            // Create a new dessert and add it to the addedDesserts so the item's quantity will be updated
            let existDessert = OrderItem(
                inventoryItem: selectedInventoryItem,
                quantity: Int(newDessertQuantity) ?? 0,
                price: selectedInventoryItem.itemPrice
            )
            addedOrderItems.append(existDessert)
            
        } else {
            // Create a new dessert and add it to the edited order
            let newDessert = OrderItem(
                inventoryItem: selectedInventoryItem,
                quantity: Int(newDessertQuantity) ?? 0,
                price: selectedInventoryItem.itemPrice
            )
            editedOrder.orderItems.append(newDessert)
            addedOrderItems.append(newDessert)
        }
        
        // Reset the input fields and validation
        newDessertQuantity = ""
        searchQuery = ""
    }
    
    private func deleteOrderItems(at indices: IndexSet) {
        let deletedOrderItemsBatch = indices.compactMap { index in
            return editedOrder.orderItems[index]
        }
        
        editedOrder.orderItems.remove(atOffsets: indices)
        addedOrderItems.remove(atOffsets: indices)
        deletedOrderItems.append(contentsOf: deletedOrderItemsBatch)
    }
    
    private func deleteOrder(order: Order) {
        orderManager.removeOrder(with: order.orderID)
    }
    
}

struct DessertEditRow: View {
    
    @Binding var dessert: OrderItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Dessert: \(dessert.inventoryItem.name)")
            
            HStack {
                Text("Quantity:")
                TextField("Enter Quantity", value: $dessert.quantity, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
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
