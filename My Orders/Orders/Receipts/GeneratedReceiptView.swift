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
    @State private var currency = HelperFunctions.getCurrencySymbol()

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
            
            Text("Receipt No. \(receipt.myID)")
                .font(.title)
                .bold()
                .padding(.bottom, 20)

            HStack{
                Text("Date Generated:")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text(HelperFunctions.formatToDate(receipt.dateGenerated)).padding(.bottom)
                
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
                List(order.orderItems, id: \.inventoryItem.name) { orderItem in
                    HStack {
                        Text("\(orderItem.inventoryItem.name)")
                        Spacer()
                        Text("Q: \(orderItem.quantity)")
                        Spacer()
                        Text("\(currency)\(orderItem.price, specifier: "%.2f")")
                    }
                }
            }
            
            if((order.delivery.address != "") || (order.delivery.cost != 0)){
                HStack {
                    Text("Delivery Cost:")
                        .font(.headline)
                    
                    let deliveryCostStr = String(format: "%.2f", order.delivery.cost)
                    let deliveryCost = currency + deliveryCostStr
                    
                    Text(deliveryCost)
                }
            }
            
            HStack{
                Text("Total Price:").font(.headline)
                let totalPriceStr = String(format: "%.2f", order.totalPrice)
                let totalPrice = currency + totalPriceStr
                Text(totalPrice)
                
            }
            
            HStack(alignment: .center, spacing: 5) {
                
                Text("Payment Method:")
                    .font(.headline)
                Text(NSLocalizedString(receipt.paymentMethod, comment: "Localized payment method"))

            }
            
            HStack(alignment: .center, spacing: 5) {
                
                Text("Payment Details:")
                    .font(.headline)
                Text("\(receipt.paymentDetails)")

            }

            HStack(alignment: .center, spacing: 5){
                Text("Payment Date:")
                    .font(.headline)
                Text(HelperFunctions.formatToDate(receipt.paymentDate))

            }
            
        }
        .padding()
        .toolbar {

            if OrderManager.shared.receiptExists(forOrderID: order.orderID) {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Button {
                        
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
                        
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }

        }
        
    }
    
}

struct GeneratedReceiptView_Previews: PreviewProvider {
    static var previews: some View {
            
        return AllReceiptsView(orderManager: OrderManager.shared)
    }
}
