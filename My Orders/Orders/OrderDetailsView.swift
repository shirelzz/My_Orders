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
    @State private var currency = HelperFunctions.getCurrencySymbol()
    
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
    
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 10) {
                
                customerInformationSection
                orderInformationSection
                
                if ((order.delivery.address != "") || (order.notes != "") || (order.allergies != "") || (order.delivery.cost != 0)) {
                    additionalDetailsSection
                }
                
                orderStatusSection
                priceSection
                
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
        .overlay(content: {
            if showInfo  {
                CustomPopUpWindow(isActive: $showInfo, item: $selectedItemForDetails, title: "Details", buttonTitle: "Close")
                    .onAppear {
                        HelperFunctions.closeKeyboard()
                    }
            }
        })
    }
    
    private var customerInformationSection: some View {
        
        //        VStack(alignment: .leading) {
        
        Section(header: Text("Customer Information")
            .font(.footnote)
            .padding(.leading, 10)
            .padding(.top, 10)
            .opacity(0.7)
                
        ) {
            VStack(alignment: .leading, spacing: 0) {
                
                Text("\(order.customer.name)")
                    .padding(.leading, 10)
                    .padding(.vertical, 10)
                
                Divider()
                    .padding(.horizontal, 8)
                    .padding(8)
                
                HStack{
                    Text(order.customer.phoneNumber)
                        .padding(.leading, 10)
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
                        .padding()
                        .tint(.green)
                    
                }
            }
            .customGraySectionVStyle()
            
        }
    }
    
    private var orderInformationSection: some View {
        Section(header: Text("Order Information")
            .font(.footnote)
            .padding(.leading, 10)
            .padding(.top, 10)
            .opacity(0.7)
        ) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text("Order Date: \(order.orderDate.formatted())")
                    .padding(.leading)
                    .padding(.vertical, 10)
                
                ForEach(order.orderItems, id: \.inventoryItem.name) { orderItem in
                    VStack(alignment: .center) {
                        HStack {
                            Text(orderItem.inventoryItem.name)
                            
                            Spacer()
                            
                            Text("Q: \(orderItem.quantity)")
                                .font(.subheadline)
                            
                            Text("\(currency)\(orderItem.price, specifier: "%.2f")")
                                .font(.subheadline)
                        }
                        .padding()
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
                    .cornerRadius(10)
                    .frame(maxWidth: HelperFunctions.getWidth())
                    .padding(8)
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
                }
            label: {
                Image(systemName: "doc.on.doc")
                    .padding()
                    .tint(.accentColor)
            }
                
                
            }
            .customVStackStyle(backgroundColor: .accentColor.opacity(0.4), cornerRadius: 15, shadowRadius: 0.0)
        }
        
    }
    
    private var additionalDetailsSection: some View {
        
        Section(header: Text("Additional Details")
            .font(.footnote)
            .padding(.leading, 10)
            .padding(.top, 10)
            .opacity(0.7)
        ) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                ScrollView {
                    
                    if((order.delivery.address != "") || (order.delivery.cost != 0)){
                        VStack(alignment: .leading) {
                            
                            Text("Delivery Address:")
                                .padding(.leading)
                            
                            HStack {
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
                                
                                Spacer()
                                
                                Text("")
                            }
                            
                            if((order.notes != "") || (order.allergies != "")){
                                Divider()
                                    .padding(.horizontal, 8)
                                    .padding(8)
                                
                            }
                        }
                        
                    }
                    
                    if order.notes != "" {
                        VStack(alignment: .leading) {
                            Text("Notes:")
                                .padding(.leading)
                            
                            HStack {
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
                                
                                
                                Spacer()
                                
                                Text("")
                            }
                            
                            if (order.allergies != "") {
                                Divider()
                                    .padding(.horizontal, 8)
                                    .padding(8)
                                
                            }
                        }
                        
                    }
                    
                    if(order.allergies != ""){
                        VStack(alignment: .leading) {
                            Text("Allergies:")
                                .padding(.leading)
                            
                            HStack {
                                Text(order.allergies)
                                    .padding(.leading)
                                
                                
                                Spacer()
                                
                                Text("")
                            }
                            
                        }
                        
                    }
                }
                
            }
            .customGraySectionVStyle()
            
        }
    }
    
    private var orderStatusSection: some View {
        Section(header: Text("Order Status")
            .font(.footnote)
            .padding(.leading, 10)
        ) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                Toggle("Paid", isOn: $order.isPaid).padding(.leading)
                    .onChange(of: order.isPaid) { newValue in
                        OrderManager.shared.updatePaymentStatus(orderID: order.id, isPaid: newValue)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                    .padding(8)
                
                Divider()
                    .padding(.horizontal, 8)
                    .padding(8)
                
                Toggle("Delivered", isOn: $order.isDelivered).padding(.leading)
                    .onChange(of: order.isDelivered) { newValue in
                        OrderManager.shared.updateOrderStatus(orderID: order.id, isDelivered: newValue)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                    .padding(8)
                
                
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
                            ReceiptView(orderManager: orderManager, order: order, showGenerationAlert: $showReceiptPreview)
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
            .customGraySectionVStyle()
            
        }
    }
    
    private var priceSection: some View {
        Section(header: Text("Price")
            .font(.footnote)
            .padding(.leading)
        ) {
            VStack(alignment: .leading, spacing: 0) {
                
                if(order.delivery.cost != 0){
                    HStack {
                        Text("Delivery Cost: ")
                            .padding(.leading)
                        
                        Spacer()
                        
                        Text("\(order.delivery.cost, specifier: "%.2f")\(currency)")
                            .padding(8)
                    }
                    //                        .padding(.leading)
                    
                }
                
                HStack{
                    Text("Total Price: ")
                        .padding(.leading)
                    
                    Spacer()
                    
                    Text("\(order.totalPrice, specifier: "%.2f") \(currency)")
                        .padding(8)
                }
                //                    .padding(.leading)
            }
            .customGraySectionVStyle()
            
        }
    }
}

#Preview {
    UpcomingOrders(orderManager: OrderManager.shared, inventoryManager: InventoryManager.shared)
}
