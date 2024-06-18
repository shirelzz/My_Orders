//
//  ReceiptView.swift
//  My Orders
//
//  Created by שיראל זכריה on 03/10/2023.
//

import SwiftUI
import PDFKit
import UIKit

struct ReceiptView: View {
    
    @ObservedObject var orderManager: OrderManager
    
    @State var order: Order
    @Binding var showGenerationAlert: Bool
    @State private var pdfData: Data?
    @State private var showConfirmationAlert = false
    @State private var selectedPaymentMethod = "Paybox"
    @State private var selectedPaymentDate: Date = Date()
    @State private var showSuccessMessage = false
    @State private var lastReceipttID = OrderManager.shared.getLastReceiptID()
    @State private var receiptExists = false
    @State private var isRewardedAdPresented = false
    @State private var currency = HelperFunctions.getCurrencySymbol()
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Receipt")
                .font(.title)
                .bold()
                .padding(.bottom, 20)
            
            HStack{
                Text("Receipt No.")
                Text(" \(lastReceipttID + 1)")
            }
            .padding(.leading)
            
            
            HStack{
                Text("Date created:")
                Text(HelperFunctions.formatToDate(Date()))
            }
            .padding(.leading)

            HStack{
                Text("For: ")
                Text(order.customer.name)
            }
            .padding(.leading)
            
            Section(header: Text("Order Details:")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.leading)
            ) {
                List(order.orderItems, id: \.inventoryItem.name) { dessert in
                    HStack {
                        Text("\(dessert.inventoryItem.name)")
                        Spacer()
                        Text("Q: \(dessert.quantity)")
                        // Text("₪\(dessert.price, specifier: "%.2f")")
                    }
                }
                
            }
            
            if((order.delivery.address != "") || (order.delivery.cost != 0)){
                HStack {
                    Text("Delivery Cost:")
                        .font(.headline)
                    Text(currency)
                    Text(String(format: "%.2f", order.delivery.cost))
                }
            }
            
            HStack{
                Text("Price:").font(.headline)
                Text(currency)
                Text(String(format: "%.2f", order.totalPrice))
                
            }
            .padding(.leading)

            
            HStack(alignment: .center, spacing: 5) {
                Text("Payment method:")
                    .font(.headline)
                
                Spacer()
                
                Picker(selection: $selectedPaymentMethod, label: Text("Payment Method")) {
                    Text("Paybox").tag("Paybox")
                    Text("Bit").tag("Bit")
                    Text("Bank transfer").tag("Bank transfer")
                    Text("Cash").tag("Cash")
                    Text("Cheque").tag("Cheque")
                }
                
            }
            .padding(.leading)

            HStack(alignment: .center, spacing: 5){
                Text("Payment date:")
                    .font(.headline)
                
                DatePicker("", selection: $selectedPaymentDate, displayedComponents: .date)
                    .datePickerStyle(DefaultDatePickerStyle())
                    .previewLayout(.sizeThatFits)

                
            }
            .padding(.leading)
            
            if !OrderManager.shared.receiptExists(forOrderID: order.orderID) {
               
                Button("Generate PDF Receipt") {
                    showConfirmationAlert = true
                }
                .padding(.top, 20)
                .alert(isPresented: $showConfirmationAlert) {
                    Alert(
                        title: Text("Generate Receipt"),
                        message: Text("Are you sure you want to generate this receipt? Once a receipt is generated it cannot be deleted."),
                        primaryButton: .default(Text("Generate").foregroundColor(Color.accentColor)) {
                            isRewardedAdPresented = true
                            generatePDF()
                            
                            if showSuccessMessage {
                                orderManager.forceReceiptNumberReset(value: 0)
                                Toast.showToast(message: "Receipt generated successfully")
                            }
                            
                        },
                        secondaryButton: .cancel(Text("Cancel").foregroundColor(Color.accentColor)) {
                        }
                    )
                }
                
//                RewardedAdView(adUnitID: "ca-app-pub-3940256099942544/1712485313", isPresented: $isRewardedAdPresented)
                // test: ca-app-pub-3940256099942544/1712485313
                // mine: ca-app-pub-1213016211458907/4894339659

            }
            
        }
        .padding()
        .toolbar {
   
            if OrderManager.shared.receiptExists(forOrderID: order.orderID) {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Button {
                        
                        pdfData = ReceiptUtils.drawPDF(for: order)
                        guard let pdfData = self.pdfData else {
                            Toast.showToast(message: "cant find data")
                            return
                        }
                        
                        if let windowScene = UIApplication.shared.connectedScenes
                            .first(where: { $0 is UIWindowScene }) as? UIWindowScene {
                            
                            let pdfShareView = SharePDFView(pdfData: pdfData)
                            let hostingController = UIHostingController(rootView: pdfShareView)
                            
                            if let rootViewController = windowScene.windows.first?.rootViewController {
                                // Dismiss any existing presented view controller
                                if let presentedViewController = rootViewController.presentedViewController {
                                    presentedViewController.dismiss(animated: true) {
                                        // Present the new view controller
                                        rootViewController.present(hostingController, animated: true, completion: nil)
                                    }
                                } else {
                                    // No view controller is currently presented, so present the new one
                                    rootViewController.present(hostingController, animated: true, completion: nil)
                                }
                            }
                        }
                        
                        
                        
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    
                }
            }
        }
    }
    
    private func checkIfReceiptExist() -> Bool {
        if OrderManager.shared.receiptExists(forOrderID: order.orderID) {
            Toast.showToast(message: "Receipt already exists")
            return true
        }
        return false
    }
    
    private func generatePDF() {
        
        if checkIfReceiptExist() {
            return
        }
        
        showGenerationAlert = true

        // Create a Receipt instance
        let receipt = Receipt(
            id: UUID().uuidString,
            myID: lastReceipttID + 1,
            orderID: order.orderID,
            dateGenerated: Date(),
            paymentMethod: selectedPaymentMethod ,
            paymentDate: selectedPaymentDate
        )
        
        if ReceiptUtils.generatePDF(order: order, receipt: receipt) != nil {
            showSuccessMessage = true
        }
    }
    
}

struct ReceiptView_Previews: PreviewProvider {
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
            notes: "",
            allergies: "",
            isDelivered: false,
            isPaid: false
            
        )
        
        return ReceiptView(orderManager: OrderManager.shared, order: sampleOrder, showGenerationAlert: .constant(false))
            .previewLayout(.sizeThatFits)
                        .padding()
    }
}

