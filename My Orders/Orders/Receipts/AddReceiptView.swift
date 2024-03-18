//
//  AddReceiptView.swift
//  My Orders
//
//  Created by שיראל זכריה on 17/03/2024.
//

import SwiftUI

struct AddReceiptView: View {
    @ObservedObject var orderManager: OrderManager
    @Binding var isPresented: Bool
    @State private var customerName = ""
    @State private var customerPhone = ""

    @State private var itemName = ""
    @State private var itemQuantity = ""
    @State private var itemCost = ""

    @State private var receiptItems: [InventoryItem] = []
    @State private var totalCost: Double = 0
    @State private var selectedPaymentMethod = "Paybox"
    @State private var selectedPaymentDate: Date = Date()
    @State private var lastReceipttID = OrderManager.shared.getLastReceiptID()
    
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
                    TextField("Phone", text: $customerPhone)

                }
                
                Section(header: Text("Receipt Items")) {
                    ForEach(receiptItems.indices, id: \.self) { index in
                        OrderItemRow(item: $receiptItems[index], onDelete: {
                            receiptItems.remove(at: index)
                            updateTotalCost()
                        })
                    }
                    
                    Button(action: {
                        
                        let item = InventoryItem(itemID: UUID().uuidString, name: itemName, itemPrice: Double(itemCost) ?? 0, itemQuantity: Int(itemQuantity) ?? 1, size: "", AdditionDate: Date(), itemNotes: "")

                        receiptItems.append(item)
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Item")
                        }
                    }
                }
                
                Section(header: Text("Total Cost")) {
                    TextField("Total Cost", value: $totalCost, format: .number)
                        .keyboardType(.decimalPad)
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
                trailing: Button("Save") {
                    saveReceipt()
                }
            )
        }
    }
    
    private func updateTotalCost() {
        totalCost = receiptItems.reduce(0) { $0 + $1.itemPrice } //fix
    }
    
    private func saveReceipt() {
        guard !customerName.isEmpty else {
            // Show validation message for empty customer name
            return
        }
        
        var orderItems: [OrderItem] = []
        for item in receiptItems {
            let orderItem = OrderItem(inventoryItem: item, quantity: item.itemQuantity, price: item.itemPrice)
        }
        
        let order = Order(orderID: UUID().uuidString,
                          customer: Customer(name: customerName, phoneNumber: "0"),
                        orderItems: orderItems)
        
        
        // Create a new receipt with the entered details
        let newReceipt = Receipt(
            id: UUID().uuidString,
            myID: lastReceipttID + 1,
            orderID: order.orderID,
            dateGenerated: Date(),
            paymentMethod: selectedPaymentMethod,
            paymentDate: selectedPaymentDate
        )
        
        // Add the new receipt to the OrderManager
        orderManager.addReceipt(receipt: newReceipt)
        
        // Show success message or navigate back
        isPresented = false
    }
}

struct ReceiptItem {
    var name: String
    var quantity: Int
    var cost: Double
}

struct OrderItemRow: View {
    @Binding var item: InventoryItem
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            TextField("Name", text: $item.name)
            
            TextField("Quantity", value: $item.itemQuantity, format: .number)
                .keyboardType(.numberPad)
            
            TextField("Cost", value: $item.itemPrice, format: .number)
                .keyboardType(.decimalPad)
            
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
