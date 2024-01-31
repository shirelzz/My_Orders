//
//  GeneratedReceiptView.swift
//  My Orders
//
//  Created by שיראל זכריה on 27/11/2023.
//

import SwiftUI
import PDFKit
import UIKit

struct GeneratedReceiptView: View {
    
    @ObservedObject var orderManager: OrderManager
    @State private var currency = AppManager.shared.currencySymbol(for: AppManager.shared.currency)

    var order: Order

    @Binding var isPresented: Bool
    @State private var pdfData: Data?
    @State private var showConfirmationAlert = false
    @State private var showSuccessMessage = false

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    
    var body: some View {
        
        let receipt = OrderManager.shared.getReceipt(forOrderID: order.orderID)

                
        VStack(alignment: .leading, spacing: 10) { //
            
            Text("Receipt")
                .font(.title)
                .bold()
                .padding(.bottom, 20)
            
            Text("Receipt No. \(receipt.myID)")

            HStack{
                Text("Date Generated:")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text("\(dateFormatter.string(from: receipt.dateGenerated))").padding(.bottom)
                
            }

            HStack{
                Text("For")
                    .bold()
                Text(order.customer.name)
            }

            Section(header:
                        Text("Order Details")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top)
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
            
            HStack(alignment: .center, spacing: 5) {
                
                Text("Payment Method:")
                    .font(.headline)
                Text("\(receipt.paymentMethod)")

            }

            HStack(alignment: .center, spacing: 5){
                Text("Payment Date:")
                    .font(.headline)
                Text("\(dateFormatter.string(from: receipt.paymentDate))")

            }

            if OrderManager.shared.receiptExists(forOrderID: order.orderID) {
                
                Button("Share PDF Receipt") {
                    pdfData = ReceiptUtils.drawPDF(for: order)
                    guard let pdfData = self.pdfData else {
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
                }
                .padding(.top, 20)
                
                
            }
            
        }
        .padding()
        
    }
    
}

struct GeneratedReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        
        let sampleItem = InventoryItem(itemID: "1234",
                                       name: "Chocolate cake",
                                       itemPrice: 20,
                                       itemQuantity: 20,
                                       size: "20",
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
        
        return GeneratedReceiptView(orderManager: OrderManager.shared, order: sampleOrder, isPresented: .constant(false))
            .previewLayout(.sizeThatFits)
                        .padding()
    }
}
