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
    @State private var selectedItemForDetails: InventoryItem = InventoryItem()
    @State private var showInfo = false
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
        
        ScrollView {
            
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
                    
                    ForEach(order.orderItems, id: \.inventoryItem.name) { orderItem in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(orderItem.inventoryItem.name)
//                                    .font(.headline)
                                Spacer()
                                Text("Q: \(orderItem.quantity)")
                                    .font(.subheadline)
                                Text("\(currency)\(orderItem.price, specifier: "%.2f")")
                                    .font(.subheadline)

                            }
//                            .padding(.horizontal)
                            .padding()
//                            .onTapGesture(perform: {
//                                selectedItemForDetails = orderItem.inventoryItem
//                            })
                            .overlay {
                                Button {
                                    selectedItemForDetails = orderItem.inventoryItem
                                    showInfo = true
                                } label: {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 14))
                                        .foregroundColor(.accentColor)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                .padding(2)
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 2)
//                        .frame(minHeight: 30)
                        .frame(maxWidth: HelperFunctions.getWidth())
                    }
                    
                    Button {
                        var orderDetailsText: String = "Date: " + order.orderDate.formatted().description + "\r\n"
                        for orderItem in order.orderItems {
                            orderDetailsText += "\r\n" +
                            orderItem.quantity.description + " " +
                            orderItem.inventoryItem.name + " " +
                            orderItem.price.description + " "
                        }
                                                
                        if order.delivery.address != "" || order.delivery.cost != 0 {
                            let deliveryTitle = "Delivery address:"
                            let deliveryCostTitle = "Delivery cost:"

                            orderDetailsText += "\r\n" + deliveryTitle + " " + order.delivery.address + "\r\n" +
                            deliveryCostTitle + " " + order.delivery.cost.description
                        }
                        
                        orderDetailsText += "\r\n" + "Total: " + order.totalPrice.description
                        
                        if order.allergies != "" {
                            let allergiesTitle = "Allergies:"
                            orderDetailsText += "\r\n" + allergiesTitle + " " + order.allergies
                        }
                        
                        if order.notes != "" {
                            let notesTitle = "Notes:"
                            orderDetailsText += "\r\n" + notesTitle + " " + order.notes
                        }
                        
                        UIPasteboard.general.string = orderDetailsText
                        Toast.showToast(message: "Order details copied")
                    } label: {
                        Text("Copy order details").padding(.leading)
                    }
                    
                }
                
                if ((order.delivery.address != "") || (order.notes != "") || (order.allergies != "") || (order.delivery.cost != 0)) {
                    Section(header:
                                Text("Additional Details")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.leading)
                    ) {
                        
                        if((order.delivery.address != "") || (order.delivery.cost != 0)){
                            VStack(alignment: .leading) {
                                Text("Delivery Address:")
                                    .padding(.leading)
                                
                                Text(order.delivery.address)
                                    .padding(.leading)
                                    .contextMenu {
                                        Button(action: {
                                            UIPasteboard.general.string = order.delivery.address
                                        }) {
                                            Text("Copy")
                                            Image(systemName: "doc.on.doc")
                                        }
                                    }
                                
                            }
                            
                        }
                        
                        if order.notes != "" {
                            VStack(alignment: .leading) {
                                Text("Notes:")
                                    .padding(.leading)
                                
                                ScrollView {
                                    Text(order.notes)
                                        .padding(.leading)
                                        .contextMenu {
                                            Button(action: {
                                                UIPasteboard.general.string = order.notes
                                            }) {
                                                Text("Copy")
                                                Image(systemName: "doc.on.doc")
                                            }
                                        }
                                }
                            }
                        }
                        
                        if(order.allergies != ""){
                            VStack(alignment: .leading) {
                                Text("Allergies:")
                                    .padding(.leading)
                                
                                Text(order.allergies)
                                    .padding(.leading)
                                
                            }
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
            .overlay(content: {
                if showInfo  {
                    CustomPopUpWindow(isActive: $showInfo, item: $selectedItemForDetails, title: "Details", buttonTitle: "Close")
                        .onAppear {
                            HelperFunctions.closeKeyboard()
                        }
                }
            })
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

