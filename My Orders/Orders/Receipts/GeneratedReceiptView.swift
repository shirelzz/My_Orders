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
    
    @Environment(\.colorScheme) var colorScheme

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            BottomRoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .light ? Color.black : Color.white)
                .frame(height: UIScreen.main.bounds.height / 2.5)
                .edgesIgnoringSafeArea(.top)
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height / 40)
                    
                    receiptInformationSection
                    
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height / 35)
                    
                    orderDetailsSection
                    
                    pricingAndPaymentSection
                    
                }
            }
        }
        .navigationBarTitle(
            Text("Receipt Details")
                .foregroundColor((colorScheme == .light ? Color.white : Color.black))
            , displayMode: .inline)
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
    
    private var receiptInformationSection: some View {
        
            VStack(alignment: .leading, spacing: 8) {
                
                let receipt = OrderManager.shared.getReceipt(forOrderID: order.orderID)
                
                HStack {
                    Text("Receipt No. \(receipt.myID)")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(colorScheme == .light ? Color.white : Color.black)
                    
                    Spacer()
                }
                
                HStack {
                    
                    Text(order.customer.name)
                        .foregroundStyle(colorScheme == .light ? Color.white : Color.black)
                    
                    Spacer()
                }
                
                HStack{
                    Text("Generated in \(HelperFunctions.formatToDate(receipt.dateGenerated))")
                        .fontWeight(.thin)
                        .foregroundStyle(colorScheme == .light ? Color.white : Color.black)
                                        
                }
                
            }
            .padding(.horizontal)
            .padding()
    }
    
    private var orderDetailsSection: some View {
        
        CustomSection(header: "Order Details", headerColor: Color.gray) {
            
            ForEach(order.orderItems, id: \.inventoryItem.name) { orderItem in
                HStack {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(orderItem.inventoryItem.name)
                            .foregroundColor(.primary)
                            .bold()
                        
                        Text("Q: \(orderItem.quantity)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(orderItem.price, specifier: "%.2f")\(currency)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private var pricingAndPaymentSection: some View {
        
        CustomSection(header: "Pricing and Payment", headerColor: Color.gray) {
            
            let receipt = OrderManager.shared.getReceipt(forOrderID: order.orderID)
            
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
                
                Divider().padding(.horizontal, 8)
                
                HStack {
                    Text("Payment Method")
                    Spacer()
                    Text(NSLocalizedString(receipt.paymentMethod, comment: "Localized payment method"))
                        .bold()
                }
                .padding(8)
                
                Divider().padding(.horizontal, 8)
                
                HStack {
                    Text("Payment Details")
                    Spacer()
                    Text("\(receipt.paymentDetails)")
                        .bold()
                }
                .padding(8)
                
                Divider().padding(.horizontal, 8)
                
                HStack {
                    Text("Payment Date")
                    Spacer()
                    Text(HelperFunctions.formatToDate(receipt.paymentDate))
                        .bold()
                }
                .padding(8)
            }
        }

    }
    
}

struct GeneratedReceiptView_Previews: PreviewProvider {
    static var previews: some View {
            
        return AllReceiptsView(orderManager: OrderManager.shared)
    }
}
