//
//  AddReceiptView.swift
//  My Orders
//
//  Created by שיראל זכריה on 17/03/2024.
//

import SwiftUI
import Combine

enum DiscountType {
    case fixedAmount
    case percentage
}

struct AddReceiptView: View {
    @ObservedObject var orderManager: OrderManager
    @Binding var isPresented: Bool
  
    @State private var order: Order = Order()
    @State private var receipt: Receipt = Receipt()
    @State private var pdfData: Data? = nil
    @State private var showingPDFPreview = false
    @State private var currency = HelperFunctions.getCurrencySymbol()
    @State private var customerName = ""
    @State private var customerPhone = ""
    @State private var isCustomerNameValid = true

    @State private var itemName = ""
    @State private var itemQuantity = ""
    @State private var itemCost = ""
    @State private var isAddingDiscount = false
    @State private var discountType: DiscountType = .fixedAmount
    @State private var discountValue = 0.0 // ""
    @State private var isItemNameValid = true
    @State private var isItemQuantityValid = true
    @State private var isItemCostValid = true
    @State private var isItemListEmpty = true
    @State private var showValidationErrors = false
    @State private var showOnlyEmptyItemListError = false
    
    @State private var receiptItems: [InventoryItem] = []
    @State private var totalCost: Double = 0
    @State private var selectedPaymentMethod = "Paybox"
    @State private var selectedPaymentDate: Date = Date()
    
    @State private var lastReceipttID = OrderManager.shared.getLastReceiptID()
    @State private var showSuccessMessage = false
    @State private var isRewardedAdPresented = false
    @State private var showConfirmationAlert = false
    @State private var isAddingDelivery = false
    
    @State private var deliveryAddress = ""
    @State private var selectedDeliveryCost: Double = 0
    let deliveryCosts: [Double] = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]
    
    
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

                    if !isCustomerNameValid && showValidationErrors {
                        Text ("Invalid name")
                            .foregroundStyle(.red)
                    }
                }
                
                Section(header: Text("Items")) {
                    
                    TextField("Name", text: $itemName)
                        .autocorrectionDisabled()
                        .onChange(of: itemName) { _ in
                            validateItemName()
                        }
                    
                    if !isItemNameValid && showValidationErrors && !showOnlyEmptyItemListError {
                        Text ("Invalid name")
                            .foregroundStyle(.red)
                    }
                    
                    HStack{
                        
                        TextField("Quantity", text: $itemQuantity)
                            .keyboardType(.numberPad)
                            .onChange(of: itemQuantity) { _ in
                                validateItemQuantity()
                            }
                        
                        TextField("Cost", text: $itemCost)
                            .keyboardType(.decimalPad)
                            .onChange(of: itemCost) { _ in
                                validateItemCost()
                            }
                        
                    }

                    if !isItemQuantityValid && showValidationErrors && !showOnlyEmptyItemListError {
                        Text ("Invalid quantity")
                            .foregroundStyle(.red)
                    }
                    
                    if !isItemCostValid && showValidationErrors && !showOnlyEmptyItemListError {
                        Text ("Invalid cost")
                            .foregroundStyle(.red)
                    }
                    
                    Button(action: {
                        
                        let item = InventoryItem(itemID: UUID().uuidString, name: itemName, itemPrice: Double(itemCost) ?? 0, itemQuantity: Int(itemQuantity) ?? 1, size: "", AdditionDate: Date(), itemNotes: "")
                        
                        receiptItems.append(item)
                        
                        itemName = ""
                        itemCost = ""
                        itemQuantity = ""
                        showValidationErrors = false
                        calculateFinalCost()
                        
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Item")
                        }
                    }
                    .disabled(itemName == "" || Int(itemQuantity) ?? 0 <= 0 || Double(itemCost) ?? 0 <= 0)
                    .buttonStyle(.borderless)
                    
                    ForEach(receiptItems, id: \.id) { item in
                        OrderItemRow(item: item) {
                            removeItem(item)
                        }
                    }
                    
                    if isItemListEmpty && showValidationErrors {
                        Text ("Add at least one item")
                            .foregroundStyle(.red)
                    }
                }
                
                Section(header: Text("Total Cost")) {
                                        
                    HStack {
                        
                        if !isAddingDiscount {
                            
                            Button {
                                isAddingDiscount = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add discount")
                                }
                            }
                            .disabled(totalCost == 0)
                            
                        } else {
                            
                            HStack {
                                
                                if discountType == .fixedAmount {
                                    TextField("\(currency)", value: $discountValue, formatter: NumberFormatter())
                                        .keyboardType(.decimalPad)
                                        .onChange(of: discountValue) { newValue in
                                            calculateFinalCost()
                                        }
                                    
                                } else {
                                    TextField("%", value: $discountValue, formatter: NumberFormatter())
                                        .keyboardType(.decimalPad)
                                        .onChange(of: discountValue) { newValue in
                                            calculateFinalCost()
                                        }
                                }
                                
                                Spacer()
                                
                                Picker("Discount Type", selection: $discountType) {
                                    Text("\(currency)")
                                        .tag(DiscountType.fixedAmount)
                                    
                                    Text("%")
                                        .tag(DiscountType.percentage)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.horizontal, 12)
                                .onChange(of: discountType) { newValue in
                                    calculateFinalCost()
                                }
                                
                                Button {
                                    discountValue = 0.0
                                    discountType = .fixedAmount
                                    calculateFinalCost()
                                    isAddingDiscount = false
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(Color.accentColor)

                                }
                                .buttonStyle(.bordered)
                                .tint(.clear)
                            }
                            
                        }
                    }
                    
                    HStack{
                        
                        if !isAddingDelivery {
                            
                            Button {
                                isAddingDelivery = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add delivery")
                                }
                            }
                        }
                        else {
                            
                            HStack {
                                TextField("Address" , text: $deliveryAddress)
                                
                                Spacer()
                                
                                Picker("", selection: $selectedDeliveryCost) {
                                    ForEach(deliveryCosts, id: \.self) { cost in
                                        Text("\(cost, specifier: "%.2f")\(currency)")
                                            .tag(cost)
                                    }
                                }
                                .pickerStyle(DefaultPickerStyle())
                                .labelsHidden()
//                                .buttonBorderShape(.automatic)
                                .onChange(of: selectedDeliveryCost) { newValue in
                                    calculateFinalCost()
                                }
                                
                                Spacer()
                                
                                Button {
                                    selectedDeliveryCost = 0
                                    deliveryAddress = ""
                                    calculateFinalCost()
                                    isAddingDelivery = false
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(Color.accentColor)
                                }
                                .buttonStyle(.bordered)
                                .tint(.clear)
                            }
                        }
                    }
                    
                    Text("Total: \(totalCost, specifier: "%.2f")")

                }
                
                Section(header: Text("Payment Details")) {
                    
                    DatePicker("Payment Date", selection: $selectedPaymentDate, in: ...Date(), displayedComponents: .date)
                    
                    Picker("Payment Method", selection: $selectedPaymentMethod) {
                        Text("Paybox").tag("Paybox")
                        Text("Bit").tag("Bit")
                        Text("Bank transfer").tag("Bank transfer")
                        Text("Cash").tag("Cash")
                        Text("Cheque").tag("Cheque")
                    }
                }
                
                Section(header: Text("Preview")) {
                    
                    Button(action: {
                        createOrder()
                        createReceipt()
                        print(receipt)
                        pdfData = ReceiptUtils.drawPreviewPDF(for: order)
                        showingPDFPreview = true
                    }) {
                        HStack {
                            Text("See receipt preview")
                            Image(systemName: "eye.circle.fill")
                        }
                    }
                    .sheet(isPresented: $showingPDFPreview) {
                        if let pdfData = pdfData {
                            PDFPreviewView(pdfData: pdfData)
                        } else {
                            Text("No PDF available")
                        }
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
                    .onTapGesture {
                        if customerName == "" || receiptItems.isEmpty {
                            
                        }
                        showValidationErrors = true
                        validateNonEmptyList()
                        if isItemListEmpty {
                            showOnlyEmptyItemListError = true
                        }

                    }
                    .alert(isPresented: $showConfirmationAlert) {
                        Alert(
                            title: Text("Generate Receipt"),
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
    
    private func validateNonEmptyList() {
        isItemListEmpty = receiptItems.isEmpty
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
    
    private func validateItemCost() {
        isItemCostValid = Double(itemCost) ?? 0 <= 0
    }
    
    private func updateTotalCost() {
        totalCost = receiptItems.reduce(0) { $0 + ($1.itemPrice * Double($1.itemQuantity)) }
    }
    
    private func calculateFinalCost() {
        updateTotalCost()
        if isAddingDiscount {
            applyDiscount()
        }
        
        if isAddingDelivery {
            applyDeliveryCost()
        }
        
        // Ensure the total cost is not negative
        totalCost = max(totalCost, 0)
    }
    
    private func applyDiscount() {
//        let discount = Double(discountValue) ?? 0.0

        if discountType == .fixedAmount {
            totalCost -= discountValue
        } else if discountType == .percentage {
            let percentage = discountValue / 100.0
            let discountAmount = totalCost * percentage
            totalCost -= discountAmount
        }
    }
    
    private func applyDeliveryCost() {
        if selectedDeliveryCost != 0 {
            totalCost += Double(selectedDeliveryCost)
        }
    }
    
    private func removeItem(_ item: InventoryItem) {
        if let index = receiptItems.firstIndex(where: { $0.id == item.id }) {
            receiptItems.remove(at: index)
            calculateFinalCost()
        }
    }
    
    private func createOrder() {
        
        var orderItems: [OrderItem] = []
        for item in receiptItems {
            let orderItem = OrderItem(inventoryItem: item, quantity: item.itemQuantity, price: item.itemPrice)
            orderItems.append(orderItem)
        }
        
        let order = Order(orderID: UUID().uuidString,
                          customer: Customer(name: customerName, phoneNumber: customerPhone),
                          orderItems: orderItems,
                          orderDate: Date(),
                          delivery: Delivery(address: deliveryAddress, cost: selectedDeliveryCost),
                          isDelivered: true,
                          isPaid: true)
        
        self.order = order
    }
    
    private func createReceipt() {
        var disAmount: Double? = nil
        var disPrecentage: Double? = nil

        if discountValue != 0.0 {
            if discountType == .fixedAmount {
                disAmount = discountValue
            }
            else if discountType == .percentage {
                disPrecentage = discountValue
            }
        }
        // Create a new receipt with the entered details
        let newReceipt = Receipt(
            id: UUID().uuidString,
            myID: lastReceipttID + 1,
            orderID: order.orderID,
            dateGenerated: Date(),
            paymentMethod: selectedPaymentMethod,
            paymentDate: selectedPaymentDate,
            discountAmount: disAmount,
            discountPercentage: disPrecentage
        )
        
        self.receipt = newReceipt
        self.order.receipt = newReceipt
    }
    
    private func saveReceipt() {
        
        createOrder()
        createReceipt()
        
        orderManager.addOrder(order: order)
        orderManager.addReceipt(receipt: receipt) // remove if using this line:
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
    @State private var currency = HelperFunctions.getCurrencySymbol()
    
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
