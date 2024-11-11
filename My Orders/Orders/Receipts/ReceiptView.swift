//
//  ReceiptView.swift
//  My Orders
//
//  Created by שיראל זכריה on 03/10/2023.
//

import SwiftUI
import PDFKit
import UIKit


import SwiftUI
import PDFKit
import UIKit

struct ReceiptView: View {
    
    @ObservedObject var orderManager: OrderManager
    @State var order: Order
    @Binding var showGenerationAlert: Bool
    
    @State private var pdfData: Data?
    @State private var showConfirmationAlert = false
    @State private var showSuccessMessage = false
    @State private var lastReceiptID = OrderManager.shared.getLastReceiptID()
    @State private var isRewardedAdPresented = false
    @State private var currency = HelperFunctions.getCurrencySymbol()
    
    @State private var selectedPaymentDate: Date = Date()
    @State private var selectedPaymentMethod = "Payment App"
    @State private var selectedPaymentApp = "Paybox"
    @State private var selectedPaymentDetails = ""
    @State private var additionalDetails = ""
    
    @Environment(\.layoutDirection) var layoutDirection  // Environment variable for detecting LTR or RTL
    
    var body: some View {
        
        Form {
            // Receipt Header Section
            Section(header: Text("Receipt Information")) {
                HStack {
                    Text("Receipt No:")
                    Spacer()
                    Text("\(lastReceiptID + 1)")
                        .multilineTextAlignment(layoutDirection == .rightToLeft ? .leading : .trailing)
                }
                
                HStack {
                    Text("Date Created:")
                    Spacer()
                    Text(HelperFunctions.formatToDate(Date()))
                        .multilineTextAlignment(layoutDirection == .rightToLeft ? .leading : .trailing)
                }
                
                HStack {
                    Text("For:")
                    Spacer()
                    Text(order.customer.name)
                        .multilineTextAlignment(layoutDirection == .rightToLeft ? .leading : .trailing)
                }
            }
            
            // Order Details Section
            Section(header: Text("Order Details")) {
                ForEach(order.orderItems, id: \.inventoryItem.name) { orderItem in
                    HStack {
                        Text(orderItem.inventoryItem.name)
                        
                        Spacer()
                        
                        Text("Q: \(orderItem.quantity)")
                        
                        Spacer(minLength: 12)
                        
                        Text("\(currency)\(String(format: "%.2f", orderItem.price))")


                    }
                    .multilineTextAlignment(layoutDirection == .rightToLeft ? .leading : .trailing)
                }
            }
            
            // Delivery Cost Section
            if !order.delivery.address.isEmpty || order.delivery.cost != 0 {
                Section(header: Text("Delivery")) {
                    HStack {
                        Text("Delivery Cost:")
                        Spacer()
                        Text("\(currency)\(String(format: "%.2f", order.delivery.cost))")
                            .multilineTextAlignment(layoutDirection == .rightToLeft ? .leading : .trailing)
                    }
                }
            }
            
            // Total Price Section
            Section(header: Text("Total Price")) {
                HStack {
                    Text("Total Price:")
                    Spacer()
                    Text("\(currency)\(String(format: "%.2f", order.totalPrice))")
                        .multilineTextAlignment(layoutDirection == .rightToLeft ? .leading : .trailing)
                }
            }
            
            // Payment Details Section
            PaymentDetailsView(
                selectedPaymentMethod: $selectedPaymentMethod,
                selectedPaymentApp: $selectedPaymentApp,
                selectedPaymentDetails: $selectedPaymentDetails,
                additionalDetails: $additionalDetails,
                selectedPaymentDate: $selectedPaymentDate
            )
            
            // Generate PDF Button
            if !OrderManager.shared.receiptExists(forOrderID: order.orderID) {
//                Section {
                    Button(action: {
                        showConfirmationAlert = true
                    }) {
                        Text("Generate Receipt")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showConfirmationAlert) {
                        Alert(
                            title: Text("Generate Receipt"),
                            message: Text("Are you sure you want to generate this receipt? Once generated, it cannot be deleted."),
                            primaryButton: .default(Text("Generate").foregroundColor(.accentColor)) {
                                isRewardedAdPresented = true
                                generatePDF()
                                if showSuccessMessage {
                                    orderManager.forceReceiptNumberReset(value: 0)
                                    Toast.showToast(message: "Receipt generated successfully")
                                }
                            },
                            secondaryButton: .cancel(Text("Cancel").foregroundColor(.red))
                        )
                    }
//                }
            }
        }
        .navigationTitle("Receipt")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if OrderManager.shared.receiptExists(forOrderID: order.orderID) {
                    Button {
                        pdfData = ReceiptUtils.drawPDF(for: order)
                        sharePDF()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    private func sharePDF() {
        guard let pdfData = self.pdfData else {
            Toast.showToast(message: "Cannot find PDF data")
            return
        }
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            
            let pdfShareView = SharePDFView(pdfData: pdfData)
            let hostingController = UIHostingController(rootView: pdfShareView)
            
            if let presentedViewController = rootViewController.presentedViewController {
                presentedViewController.dismiss(animated: true) {
                    rootViewController.present(hostingController, animated: true)
                }
            } else {
                rootViewController.present(hostingController, animated: true)
            }
        }
    }
    
    private func generatePDF() {
        if checkIfReceiptExists() { return }
        
        showGenerationAlert = true
        let receipt = Receipt(
            id: UUID().uuidString,
            myID: lastReceiptID + 1,
            orderID: order.orderID,
            dateGenerated: Date(),
            paymentMethod: selectedPaymentMethod,
            paymentDate: selectedPaymentDate
        )
        
        if ReceiptUtils.generatePDF(order: order, receipt: receipt) != nil {
            showSuccessMessage = true
        }
    }
    
    private func checkIfReceiptExists() -> Bool {
        if OrderManager.shared.receiptExists(forOrderID: order.orderID) {
            Toast.showToast(message: "Receipt already exists")
            return true
        }
        return false
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

