import SwiftUI

struct OrderDetailsView1: View {
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
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Half-Circle Background
                    RoundedRectangle(cornerRadius: geometry.size.width / 2)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width, height: 200)
                        .overlay(
                            VStack {
                                Text("Order Details")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.top, 50)
                            }
                        )
                        .edgesIgnoringSafeArea(.top)
                    
                    // Content Sections
                    VStack(spacing: 16) {
                        Form {
                            customerInformationSection
                            orderInformationSection
                            
                            if !order.delivery.address.isEmpty || !order.notes.isEmpty || !order.allergies.isEmpty || order.delivery.cost != 0 {
                                additionalDetailsSection
                            }
                            
                            orderStatusSection
                            priceSection
                        }
                        .background(Color(.systemBackground)) // Matches the form background color
                        .cornerRadius(12)
                        .padding(.top, -40) // Moves the form up slightly to overlap with the background
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationBarTitle("Order Details", displayMode: .inline)
        .navigationBarItems(
            trailing:
                Button(action: {
                    isEditing.toggle()
                }) {
                    Image(systemName: isEditing ? "pencil.slash" : "pencil")
                        .font(.system(size: 18))
                        .foregroundColor(isEditing ? .red : .white)
                }
        )
        .sheet(isPresented: $isEditing) {
            EditOrderView(orderManager: orderManager, inventoryManager: inventoryManager, order: $order, editedOrder: order)
        }
        .overlay(content: {
            if showInfo {
                CustomPopUpWindow(isActive: $showInfo, item: $selectedItemForDetails, title: "Details", buttonTitle: "Close")
                    .onAppear {
                        HelperFunctions.closeKeyboard()
                    }
            }
        })
    }
    
    private var customerInformationSection: some View {
        Section(header: Text("Customer Information")) {
            VStack {
                HStack {
                    Text("Name:")
                    Text(order.customer.name)
                }
                WhatsAppChatButton(phoneNumber: order.customer.phoneNumber)
                    .padding()
                    .tint(.accentColor)
            }
        }
    }
    
    private var orderInformationSection: some View {
        Section(header: Text("Order Information")) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.accentColor)
                Text("Order Date: \(order.orderDate.formatted(date: .abbreviated, time: .shortened))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)
            
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
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color(.black).opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        .cornerRadius(12)
    }
    
    private var additionalDetailsSection: some View {
        Section(header: Text("Additional Details")) {
            VStack {
                if !order.delivery.address.isEmpty || order.delivery.cost != 0 {
                    CustomSectionView(
                        title: "Deliver to",
                        address: order.delivery.address,
                        sfSymbol: "mappin.and.ellipse"
                    )
                }
                
                if !order.notes.isEmpty {
                    CustomSectionView(
                        title: "Notes",
                        address: order.notes,
                        sfSymbol: "note.text"
                    )
                }
                
                if !order.allergies.isEmpty {
                    CustomSectionView(
                        title: "Allergies",
                        address: order.allergies,
                        sfSymbol: "allergens"
                    )
                }
            }
        }
    }
    
    private var orderStatusSection: some View {
        Section(header: Text("Order Status")) {
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
            .customGraySectionVStyle()
        }
    }
    
    private var priceSection: some View {
        Section(header: Text("Price")) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Delivery Cost")
                    Spacer()
                    Text("\(order.delivery.cost, specifier: "%.2f")\(currency)")
                        .bold()
                }
                .padding(8)
                
                HStack {
                    Text("Total Price")
                    Spacer()
                    Text("\(order.totalPrice, specifier: "%.2f")\(currency)")
                        .bold()
                }
                .padding(8)
            }
            .customGraySectionVStyle()
        }
    }
}

#Preview {
    
    OrderDetailsView1(orderManager: OrderManager.shared, inventoryManager: InventoryManager.shared,
                      order: Order(orderID: "123", customer: Customer(name: "Shir", phoneNumber: "076"), orderItems: [OrderItem(inventoryItem: InventoryItem(itemID: "111", name: "Cake", itemPrice: 120, itemQuantity: 4, size: "medium", AdditionDate: Date(), itemNotes: ""), quantity: 1, price: 120)], orderDate: Date(), delivery: Delivery(address: "Ariel", cost: 25), notes: "", allergies: "", isDelivered: false, isPaid: true)
                      )

}
