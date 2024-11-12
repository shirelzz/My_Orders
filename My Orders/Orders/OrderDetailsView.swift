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
    @Environment(\.colorScheme) var colorScheme // Detects light or dark mode
    
    // Set the color based on the color scheme
    var orderInformationSectionHeaderColor: Color {
        colorScheme == .light ? Color.gray : Color.gray
    }
    
    var sectionHeadersColor: Color {
        colorScheme == .light ? Color.gray : Color.gray
    }

    var body: some View {
        
        ZStack(alignment: .top) {
            
            BottomRoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .light ? Color.black : Color.white)
                .frame(height: UIScreen.main.bounds.height / 2.5)
                .edgesIgnoringSafeArea(.top)
            
            ScrollView {
                
                VStack(spacing: 12) {
                    // Spacer to create initial offset, making content start lower
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height / 25)
                    
                    // Customer Information Section
                    customerInformationSection
                        .cornerRadius(12)
                    
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height / 35)
                    
                    // Order Information Section
                    orderInformationSection
                        .cornerRadius(12)
                    
                    // Additional Details Section (if any details are present)
                    if !order.delivery.address.isEmpty || !order.notes.isEmpty || !order.allergies.isEmpty || order.delivery.cost != 0 {
                        additionalDetailsSection
                            .cornerRadius(12)
                    }
                    
                    // Order Status Section
                    orderStatusSection
                        .cornerRadius(12)
                    
                    // Price Section
                    priceSection
                        .cornerRadius(12)
                }
                .padding(.bottom, 20) // Padding at the bottom for spacing
            }
        }
        .background(colorScheme == .light ? Color.white : Color.black)
        .navigationBarTitle(
            Text("Order Details")
                .foregroundColor((colorScheme == .light ? Color.white : Color.black))
            , displayMode: .inline)
        .navigationBarItems(
            trailing:
                Button(action: {
                    isEditing.toggle()
                }) {
                    Image(systemName: isEditing ? "pencil.slash" : "pencil")
                        .font(.system(size: 18))
                        .foregroundColor(isEditing ? .red : (colorScheme == .light ? .white : .black))
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

    
    private var customerInformationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(order.customer.name)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(colorScheme == .light ? Color.white : Color.black)
                
                Spacer()
            }
            
            HStack {
                
                Text(order.customer.phoneNumber)
                    .foregroundStyle(colorScheme == .light ? Color.white : Color.black)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = order.customer.phoneNumber
                        }) {
                            Text("Copy Phone Number")
                            Image(systemName: "doc.on.doc")
                        }
                    }

                WhatsAppChatButton(phoneNumber: order.customer.phoneNumber)
                    .tint(colorScheme == .light ? Color.white : Color.black)
                
                Spacer()
            }
            
        }
        .padding(.horizontal)
        .padding()
    }
    
    private var orderInformationSection: some View {
        CustomSection(header: "Order Information", headerColor: orderInformationSectionHeaderColor) {
            HStack(alignment: .center) {
                Image(systemName: "calendar")
                    .foregroundColor(.accentColor)
                
                Text(order.orderDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.vertical, 8)
            
            ForEach(order.orderItems, id: \.inventoryItem.name) { orderItem in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(orderItem.inventoryItem.name)
                            .foregroundColor(.primary)
                            .bold()
                        
                        Text("Quantity: \(orderItem.quantity)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(orderItem.price, specifier: "%.2f")\(currency)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        selectedItemForDetails = orderItem.inventoryItem
                        showInfo = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.accentColor)
                            .padding(8)
                            .background(Color(.clear))
                            .clipShape(Circle())
                    }
                    .animation(.easeInOut, value: showInfo)
                }
            }
        }
        .cornerRadius(12)
    }
    
    private var additionalDetailsSection: some View {
        CustomSection(header: "Additional Details", headerColor: sectionHeadersColor) {
            VStack {
                if !order.delivery.address.isEmpty || order.delivery.cost != 0 {
                    CustomSectionView(
                        title: "Deliver to",
                        description: order.delivery.address,
                        sfSymbol: "mappin.and.ellipse"
                    )
                    
                    if !order.notes.isEmpty {
                        Divider()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)

                    }

                }
                
                if !order.notes.isEmpty {
                    CustomSectionView(
                        title: "Notes",
                        description: order.notes,
                        sfSymbol: "note.text"
                    )
                    
                    if !order.allergies.isEmpty {
                        Divider()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)

                    }
                    
                }
                
                if !order.allergies.isEmpty {
                    
                    CustomSectionView(
                        title: "Allergies",
                        description: order.allergies,
                        sfSymbol: "allergens"
                    )
                }
            }
        }
    }
    
    private var orderStatusSection: some View {
        CustomSection(header: "Order Status", headerColor: sectionHeadersColor) {
            VStack(alignment: .leading) {
                Toggle("Paid", isOn: $order.isPaid)
                    .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                    .padding(8)
                
                Divider().padding(.horizontal, 8)
                
                Toggle("Delivered", isOn: $order.isDelivered)
                    .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                    .padding(8)
                
                if order.isPaid {
                    Button("Show Receipt Details") {
                        if orderManager.receiptExists(forOrderID: order.orderID) {
                            showGeneratedReceiptPreview = true
                        } else {
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
                }
            }
        }
    }
    
    private var priceSection: some View {
        CustomSection(header: "Price", headerColor: sectionHeadersColor) {
            VStack(alignment: .leading) {
                
                HStack {
                    Text("Delivery Cost")
                    Spacer()
                    Text("\(order.delivery.cost, specifier: "%.2f")\(currency)")
                        .bold()
                }
                .padding(8)
                
                Divider().padding(.horizontal, 8)
                
                HStack {
                    Text("Total Price")
                    Spacer()
                    Text("\(order.totalPrice, specifier: "%.2f")\(currency)")
                        .bold()
                }
                .padding(8)
            }
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
        
        let sampleItem_ = InventoryItem(itemID: "4321",
                                        name: "Raspberry pie",
                                        itemPrice: 120,
                                        itemQuantity: 3,
                                        size: "",
                                        AdditionDate: Date(),
                                        itemNotes: ""
        )
        
        let sampleOrder = Order(
            orderID: "1234",
            customer: Customer(name: "John Doe", phoneNumber: "0546768900"),
            orderItems: [OrderItem(inventoryItem: sampleItem, quantity: 2,price: sampleItem.itemPrice),
                         OrderItem(inventoryItem: sampleItem_, quantity: 1, price: sampleItem_.itemPrice)],
            orderDate: Date(),
            delivery: Delivery(address: "yefe nof 18, peduel", cost: 10),
            notes: "Blessing to me!!",
            allergies: "",
            isDelivered: false,
            isPaid: false
            
        )
        
        return OrderDetailsView(orderManager: OrderManager(), inventoryManager: InventoryManager(), order: sampleOrder)
        
        
    }
}

//
//#Preview {
//    UpcomingOrders(orderManager: OrderManager.shared, inventoryManager: InventoryManager.shared)
//}
