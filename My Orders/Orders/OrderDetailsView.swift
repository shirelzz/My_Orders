//
//  OrderDetailsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct OrderDetailsView: View {
    @ObservedObject var orderManager: OrderManager
    @ObservedObject var inventoryManager: InventoryManager
    @ObservedObject var languageManager: LanguageManager
    
    @State var order: Order
    @State private var showReceipt = false
    @State private var showReceiptPreview = false
    @State private var isEditing = false
    
    var flag = false
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Section(header: Text("Customer Information")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.leading)
            ) {
                HStack{
                    Text("Name:")
                    Text((order.customer.name))
                }
                .padding(.leading)

                HStack{
                    Text("Phone: \(order.customer.phoneNumber)")
                    
                    WhatsAppChatButton(phoneNumber: order.customer.phoneNumber)

                }
                .padding(.leading)
            }
            
            Section(header: Text("Order Information")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.leading)
            ) {
                
                HStack{
                    Text("Order Date:")
                    Text(order.orderDate.formatted())
                }
                .padding(.leading)
                
                List(order.desserts, id: \.inventoryItem.name) { dessert in
                    HStack {
                        Text("\(dessert.inventoryItem.name)")
                        Spacer()
                        Text("Q: \(dessert.quantity)")
                        Text("$\(dessert.price, specifier: "%.2f")")
                    }
                    .padding(.leading)

                }
            }
            
            if (order.delivery.address != "" || order.notes != "" || order.allergies != "") {
                Section(header:
                     Text("Additional Details")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.leading)
                ) {
                    
                    if(order.delivery.address != ""){
                        HStack {
                            Text("Delivery Address:")
                            Text(order.delivery.address)
                        }
                        .padding(.leading)

                    }
                    
                    if(order.notes != ""){
                        HStack {
                            Text("Notes:")
                            Text(order.notes)
                        }
                        .padding(.leading)
                    }
                    
                    if(order.allergies != ""){
                        HStack{
                            Text("Allergies:")
                            Text(order.allergies)
                        }
                        .padding(.leading)
                    }
                    
                }
            }
            
            Section(header:
                        Text("Order Status")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.leading)
            ) {
                
                Toggle("Paid", isOn: $order.isPaid).padding(.leading)
                    .onChange(of: order.isPaid) { newValue in
                        OrderManager.shared.updatePaymentStatus(orderID: order.id, isPaid: newValue)
                    }
                
                Toggle("Delivered", isOn: $order.isDelivered).padding(.leading)
                    .onChange(of: order.isDelivered) { newValue in
                        if !flag{
                            OrderManager.shared.updateOrderStatus(orderID: order.id, isDelivered: newValue)
                        }
                        
                    }
                
                if order.isPaid {
                    Button("Show Preview") {
                        showReceiptPreview = true
                    }
                    .sheet(isPresented: $showReceiptPreview) {
                        NavigationView {
                            ReceiptView(orderManager: orderManager, languageManager: languageManager, order: order, isPresented: $showReceiptPreview)
                        }
                    }
                    .padding(.leading)
                }
            }
            
            
            Section(header:
                        Text("Price")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.leading)
            ) {
                
                if(order.delivery.cost != 0){
                    HStack {
                        Text("Delivery Cost: $")
                        Text("\(order.delivery.cost, specifier: "%.2f")")
                    }
                    .padding(.leading)

                }
                
                HStack{
                    Text("Total Price: $")
                    Text("\(order.totalPrice, specifier: "%.2f")")
                }
                .padding(.leading)
            }
        }
        .padding()
        .navigationBarTitle("Order Details")
        .navigationBarItems(trailing:
                        Button(action: {
                            isEditing.toggle()
                        }) {
                            Text(isEditing ? "Done" : "Edit")
                        }
                    )
                    .sheet(isPresented: $isEditing) {
                        EditOrderView(orderManager: orderManager, inventoryManager: inventoryManager, order: $order, editedOrder: order)
                        // ^ Create a new view for editing and pass the order binding
                    }
//        .sheet(isPresented: $showReceipt) {
//            ReceiptView(order: order, isPresented: $showReceipt) // Present receipt view when the state variable is true
//        }
    }
}
    

struct OrderDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let sampleItem = InventoryItem(name: "Chocolate cake",
                                       itemPrice: 20,
                                       itemQuantity: 20,
                                       size: "",
                                       AdditionDate: Date(),
                                       itemNotes: ""
                                       )
                                       
        
            let sampleOrder = Order(
                orderID: "123",
                customer: Customer(name: "John Doe", phoneNumber: "0546768900"),
                
                desserts: [Dessert(inventoryItem: sampleItem, quantity: 2, price: 10.0)],
                
                orderDate: Date(),
                delivery: Delivery(address: "yefe nof 18, peduel", cost: 10) ,
                notes: "",
                allergies: "",
                isDelivered: false,
                isPaid: false,
                receipt: nil
            )
            
        OrderDetailsView(orderManager: OrderManager.shared, inventoryManager: InventoryManager.shared, languageManager: LanguageManager.shared, order: sampleOrder)
    }
}

