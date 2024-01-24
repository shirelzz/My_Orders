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
    @State private var currency = AppManager.shared.currencySymbol(for: AppManager.shared.currency)

    @State var order: Order

    @State private var showReceipt = false
    @State private var showReceiptPreview = false
    @State private var showGeneratedReceiptPreview = false
    @State private var showSomeReceiptPreview = false

    @State private var isEditing = false
    
    @State private var phoneNumberCopied = false
    @State private var phoneNumberToCopy = ""
        
    @Environment(\.presentationMode) var presentationMode

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
                    Text("Name: \(order.customer.name)")
                }
                .padding(.leading)
                
                HStack{
                    Text("Phone: ")
                    Text(order.customer.phoneNumber)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = order.customer.phoneNumber
                            }) {
                                Text("Copy Phone Number")
                                Image(systemName: "doc.on.doc")
                            }
                        }
                    
                    Spacer()

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
                
                List(order.orderItems, id: \.inventoryItem.name) { orderItem in
                    VStack (alignment: .center, spacing: 10) {
                        HStack {
                            Text("\(orderItem.inventoryItem.name)")
                            Spacer()
                            Text("Q: \(orderItem.quantity)")
                            Text("\(currency)\(orderItem.price, specifier: "%.2f")")
                        }
                        .padding(.leading)
                    }
                }
                
                Button {
                    var orderDetailsText: String = "Date: " + order.orderDate.formatted().description + "\r\n"
                    for orderItem in order.orderItems {
                        orderDetailsText += "\r\n" +
                                            orderItem.quantity.description + " " +
                                            orderItem.inventoryItem.name + " " +
                                            orderItem.price.description + " "
                    }
                    
                    if order.delivery.address != "" {
                        orderDetailsText += "\r\n" + "Delivery address: " + order.delivery.address + "\r\n" +
                        "Delivery cost" + order.delivery.cost.description
                    }
                    
                    orderDetailsText += "\r\n" + "Total: " + order.totalPrice.description
                    
                    if order.allergies != "" {
                        orderDetailsText += "\r\n" + "Allergies: " + order.allergies
                    }
                    
                    UIPasteboard.general.string = orderDetailsText
                    Toast.showToast(message: "Order details copied")
                } label: {
                    Text("Copy order details").padding(.leading)
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
            
            Section(header: Text("Order Status")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.leading)
            ) {
                
                Toggle("Paid", isOn: $order.isPaid).padding(.leading)
                    .onChange(of: order.isPaid) { newValue in
                        OrderManager.shared.updatePaymentStatus(orderID: order.id, isPaid: newValue)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))

                Toggle("Delivered", isOn: $order.isDelivered).padding(.leading)
                    .onChange(of: order.isDelivered) { newValue in
                        OrderManager.shared.updateOrderStatus(orderID: order.id, isDelivered: newValue)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))

                
                if order.isPaid {
                    Button("Show Receipt Preview") {
                        if orderManager.receiptExists(forOrderID: order.orderID){
                            showGeneratedReceiptPreview = true
                        }
                        else {
                            showReceiptPreview = true
                        }
                    }
                    .sheet(isPresented: $showReceiptPreview) {
                        NavigationView {
                            ReceiptView(orderManager: orderManager, order: order, isPresented: $showReceiptPreview)
                        }
                    }
                    .sheet(isPresented: $showGeneratedReceiptPreview) {
                        NavigationView {
                            GeneratedReceiptView(orderManager: orderManager, order: order, isPresented: $showGeneratedReceiptPreview)
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
                        Text("Delivery Cost: \(currency)")
                        Text("\(order.delivery.cost, specifier: "%.2f")")
                    }
                    .padding(.leading)

                }
                
                HStack{
                    Text("Total Price: \(currency)")
                    Text("\(order.totalPrice, specifier: "%.2f")")
                }
                .padding(.leading)
            }
        }
        .padding()
        .navigationBarTitle("Order Details")
        .navigationBarItems(
                            
                        trailing: 
                                
                            Button(action: {
                                isEditing.toggle()
                            }) {
                                Text(isEditing ? "Done" : "Edit")
                            }
                    )
        .sheet(isPresented: $isEditing) {
            EditOrderView(orderManager: orderManager, inventoryManager: inventoryManager, order: $order, editedOrder: order)
            
        }
    }
}
    

struct OrderDetailsView_Previews: PreviewProvider {


    static var previews: some View {

        let sampleItem = InventoryItem(itemID: "1234",
                                       name: "Chocolate cake",
                                       itemPrice: 20,
                                       itemQuantity: 20,
                                       size: "",
                                       AdditionDate: Date(),
                                       itemNotes: ""
                                       )
                                       
        
            let sampleOrder = Order(
                orderID: "123",
                customer: Customer(name: "John Doe", phoneNumber: "0546768900"),
                
                orderItems: [OrderItem(inventoryItem: sampleItem, quantity: 2, price: 10.0)],
                
                orderDate: Date(),
                delivery: Delivery(address: "yefe nof 18, peduel", cost: 10) ,
                notes: "",
                allergies: "",
                isDelivered: false,
                isPaid: false
            )
            
        OrderDetailsView(orderManager: OrderManager.shared, inventoryManager: InventoryManager.shared, order: sampleOrder)
    }
}

