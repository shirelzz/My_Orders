//
//  AddReceiptView.swift
//  My Orders
//
//  Created by שיראל זכריה on 17/03/2024.
//

import SwiftUI
import Combine

struct AddReceiptView: View {
    @ObservedObject var orderManager: OrderManager
    @Binding var isPresented: Bool
    @State private var customerName = ""
    @State private var customerPhone = ""
    @State private var isCustomerNameValid = true

    @State private var itemName = ""
    @State private var itemQuantity = ""
    @State private var itemCost = ""
    @State private var isItemNameValid = true
    @State private var isItemQuantityValid = true

    @State private var receiptItems: [InventoryItem] = []
    @State private var totalCost: Double = 0
    @State private var selectedPaymentMethod = "Paybox"
    @State private var selectedPaymentDate: Date = Date()
    
    @State private var lastReceipttID = OrderManager.shared.getLastReceiptID()
    @State private var showSuccessMessage = false
    @State private var isRewardedAdPresented = false
    @State private var showConfirmationAlert = false
    
    
    var body: some View {
        NavigationStack {
            Form {
                
                HStack{
                    Text("Receipt No.")
                    Text(" \(lastReceipttID + 1)")
                }
                .padding(.leading)
                
                Section(header: Text("Customer Details")) {
                    TextField("Name", text: $customerName)
                        .autocorrectionDisabled()
                        .onChange(of: customerName) { _ in
                            validateCustomerName()
                        }
                    
                    TextField("Phone", text: $customerPhone)
                        .keyboardType(.numberPad)

                    if !isCustomerNameValid {
                        Text ("Invalid name")
                            .foregroundStyle(.red)
                    }
                }
                
                Section(header: Text("Receipt Items")) {
                    ForEach(receiptItems, id: \.id) { item in
                        OrderItemRow(item: item) {
                            removeItem(item)
                        }
                    }
                    
                    HStack{
                        
                        TextField("Name", text: $itemName)
                            .autocorrectionDisabled()
                            .onChange(of: itemName) { _ in
                                validateItemName()
                            }
                        
                        TextField("Quantity", text: $itemQuantity)
                            .keyboardType(.numberPad)
                            .onChange(of: itemQuantity) { _ in
                                validateItemQuantity()
                            }
                        
                        TextField("Cost", text: $itemCost)
                            .keyboardType(.decimalPad)
                        
                    }
                    
                    if !isItemNameValid {
                        Text ("Invalid name")
                            .foregroundStyle(.red)
                    }
                    
                    if !isItemQuantityValid {
                        Text ("Invalid quantity")
                            .foregroundStyle(.red)
                    }
                    
                    Button(action: {
                        
                        let item = InventoryItem(itemID: UUID().uuidString, name: itemName, itemPrice: Double(itemCost) ?? 0, itemQuantity: Int(itemQuantity) ?? 1, size: "", AdditionDate: Date(), itemNotes: "")
                        
                        receiptItems.append(item)
                        
                        itemName = ""
                        itemCost = ""
                        itemQuantity = ""
                        
                        updateTotalCost()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Item")
                        }
                    }
                    .disabled(itemName == "" || Int(itemQuantity) ?? 0 <= 0 || Double(itemCost) ?? 0 <= 0)
                }
                
                Section(header: Text("Total Cost")) {
                    HStack {
                        Text("Total: \(totalCost, specifier: "%.2f")")
                        
//                        Button {
//                            isAddingDiscount = true
//                        } label: {
//                            Text("Add discount")
//                        }

                    }
                    
                    

//                    TextField("Total Cost", value: $totalCost, format: .number)
//                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Payment Details")) {
                    
                    DatePicker("Payment Date", selection: $selectedPaymentDate, displayedComponents: .date)
                    
                    Picker("Payment Method", selection: $selectedPaymentMethod) {
                        Text("Paybox").tag("Paybox")
                        Text("Bit").tag("Bit")
                        Text("Bank transfer").tag("Bank transfer")
                        Text("Cash").tag("Cash")
                    }
                }
            }
            .navigationBarTitle("Create New Receipt")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing:
                    Button("Generate") {
                        showConfirmationAlert = true
                    }
                    .disabled(customerName == "" || receiptItems.isEmpty)
                    .alert(isPresented: $showConfirmationAlert) {
                        Alert(
                            title: Text("Gen erate Receipt"),
                            message: Text("Are you sure you want to generate this receipt? Once a receipt is generated it cannot be deleted."),
                            primaryButton: .default(Text("Generate").foregroundColor(Color.accentColor)) {
                                isRewardedAdPresented = true
                                saveReceipt()

                                if showSuccessMessage {
                                    orderManager.forceReceiptNumberReset(value: 0)
                                    Toast.showToast(message: "Receipt generated successfully")
                                }
                                
                            },
                            secondaryButton: .cancel(Text("Cancel").foregroundColor(Color.accentColor)) {
                            }
                        )
                    }
            )
        }
    }
    
    private func validateCustomerName() {
        isCustomerNameValid = customerName != ""
    }
    
    private func validateItemName() {
        isItemNameValid = itemName != ""
    }
    
    private func validateItemQuantity() {
        isItemQuantityValid = Int(itemQuantity) ?? 0 > 0
    }
    
    func updateTotalCost() {
        totalCost = receiptItems.reduce(0) { $0 + ($1.itemPrice * Double($1.itemQuantity)) }
    }
    
    private func removeItem(_ item: InventoryItem) {
        if let index = receiptItems.firstIndex(where: { $0.id == item.id }) {
            receiptItems.remove(at: index)
            updateTotalCost()
        }
    }
    
    private func saveReceipt() {
        guard !customerName.isEmpty else {
            // Show validation message for empty customer name
            return
        }
        
        var orderItems: [OrderItem] = []
        for item in receiptItems {
            let orderItem = OrderItem(inventoryItem: item, quantity: item.itemQuantity, price: item.itemPrice)
            orderItems.append(orderItem)
        }
        
        let order = Order(orderID: UUID().uuidString,
                            customer: Customer(name: customerName, phoneNumber: "0"),
                            orderItems: orderItems,
                            isDelivered: true,
                            isPaid: true)
                
        // Create a new receipt with the entered details
        let newReceipt = Receipt(
            id: UUID().uuidString,
            myID: lastReceipttID + 1,
            orderID: order.orderID,
            dateGenerated: Date(),
            paymentMethod: selectedPaymentMethod,
            paymentDate: selectedPaymentDate
        )
        
        orderManager.addOrder(order: order)
        orderManager.addReceipt(receipt: newReceipt) // remove if using this line:
//        if let _pdfData = ReceiptUtils.generatePDF(order: order, receipt: receipt) {
//            showSuccessMessage = true
//        }
        
        // Show success message or navigate back
        showSuccessMessage = true
        isPresented = false
    }

}

struct ReceiptItem {
    var name: String
    var quantity: Int
    var cost: Double
}

struct OrderItemRow: View {
    var item: InventoryItem
    var onDelete: () -> Void
    @State private var currency = AppManager.shared.currencySymbol(for: AppManager.shared.currency)
    
    var body: some View {
        HStack {
            Text(item.name)
            
            Spacer()

            Text("\(item.itemQuantity)")
            
            Spacer()

            Text("\(item.itemPrice, specifier: "%.2f")\(currency)")
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
            }
        }
    }
}


struct AddReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        let orderManager = OrderManager()
        return AddReceiptView(orderManager: orderManager, isPresented: .constant(false))
    }
}
