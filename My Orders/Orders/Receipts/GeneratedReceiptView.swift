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
    
    @ObservedObject var orderManager: OrderManager //n
//    @ObservedObject var languageManager: LanguageManager
    
    var order: Order //@state
    //@state

    //    let order: Order

    
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
            
//            Text("קבלה מספר \(order.receipt?.myID ?? 0)")
            Text("Receipt No. \(receipt.myID)")
//            HStack {
//                Text("Receipt No.\(orderManager.getReceipt(forOrderID: order.orderID).myID)")
//                    }


            HStack{
                Text("Date Generated:")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
//                if let dateGenerated = order.receipt?.dateGenerated {
//                    Text("\(dateFormatter.string(from: dateGenerated))").padding(.bottom)
//                } else {
//                    // Handle the case when dateGenerated is nil
//                    Text("N/A").padding(.bottom)
//                }
                Text("\(dateFormatter.string(from: receipt.dateGenerated))").padding(.bottom)
                
            }
//            .environment(\.layoutDirection, languageManager.currentLanguage.layoutDirection)

            HStack{
                Text("For")
                    .bold()
                Text(order.customer.name)
            }
//            .environment(\.layoutDirection, languageManager.currentLanguage.layoutDirection)

            Section(header:
                        Text("Order Details")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top)
            ) {
                List(order.desserts, id: \.inventoryItem.name) { dessert in
                    HStack {
                        Text("\(dessert.inventoryItem.name)")
                        Spacer()
                        Text("Q: \(dessert.quantity)")
                        // Text("₪\(dessert.price, specifier: "%.2f")")
                    }
                }
            }
            
            HStack{
                Text("Price:").font(.headline)
                Text("$")
                Text(String(format: "%.2f", order.totalPrice))
                
            }
            
            HStack(alignment: .center, spacing: 5) {
                
                Text("Payment Method:")
                    .font(.headline)
//                Text("\(order.receipt?.paymentMethod ?? "")")
                Text("\(receipt.paymentMethod)")

            }
//            .environment(\.layoutDirection, languageManager.currentLanguage.layoutDirection)

            HStack(alignment: .center, spacing: 5){
                Text("Payment Date:")
                    .font(.headline)
//                Text("\(dateFormatter.string(from: order.receipt?.paymentDate ?? Date()))")
                Text("\(dateFormatter.string(from: receipt.paymentDate))")

            }
            
//            Text("receipt exist: \(OrderManager.shared.receiptExists(forOrderID: order.orderID).description)")
//                .environment(\.layoutDirection, languageManager.currentLanguage.layoutDirection)

            
//            if !OrderManager.shared.receiptExists(forOrderID: order.orderID) {
//
//            }
            

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
            
            
//            if OrderManager.shared.receiptExists(forOrderID: order.orderID) {
//                Button("Share PDF Receipt") {
//                    guard let pdfData = self.pdfData else {
//                        return
//                    }
//                    
//                    if let windowScene = UIApplication.shared.connectedScenes
//                        .first(where: { $0 is UIWindowScene }) as? UIWindowScene {
//                        
//                        let pdfShareView = SharePDFView(pdfData: pdfData)
//                        let hostingController = UIHostingController(rootView: pdfShareView)
//                        
//                        if let rootViewController = windowScene.windows.first?.rootViewController {
//                            rootViewController.present(hostingController, animated: true, completion: nil)
//                        }
//                    }
//                }
//                .padding(.top, 20)
//            }
            
        }
        .padding()
        
    }
    
    
    
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }
    
//    private func generatePDF() {
//        // Check if a receipt with the same order ID already exists
//        if OrderManager.shared.receiptExists(forOrderID: order.orderID) {
//            isPresented = true
//            return
//        }
//        
//        let pdfData = drawPDF()
//        
//        // Specify the file URL where you want to save the PDF
//        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("receipt.pdf") else {
//            return
//        }
//        
//        // Save the PDF to the file URL
//        do {
//            try pdfData.write(to: fileURL)
//            self.pdfData = pdfData
//            
//            // Log the file path
//            print("PDF file saved to: \(fileURL)")
//            
//            let receipt = order.receipt
//            
//            isPresented = true
//            
//            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//                do {
//                    let files = try FileManager.default.contentsOfDirectory(atPath: documentDirectory.path)
//                    print("Files in document directory: \(files)")
//                } catch {
//                    print("Error listing files in document directory: \(error.localizedDescription)")
//                }
//            }
//            
//            showSuccessMessage = true
//            
//            
//        } catch {
//            print("Error saving PDF: \(error.localizedDescription)")
//        }
//    }
    
    
    
    private func drawPDF(receipt: Receipt) -> Data {
        
//        let en = LanguageManager.shared.getCurrentLanguage() == "english"
        
        // Fetch the preferred localization
        let preferredLanguage = Bundle.main.preferredLocalizations.first ?? "en"
        
        // Check the language and set your conditions accordingly
        let en = preferredLanguage == "en"
        let he = preferredLanguage == "he"

        // Create a PDF context
        let pdfMetaData = [
            kCGPDFContextCreator: "My Orders",
            kCGPDFContextAuthor: "Shirel Turgeman"
        ]
        let pdfFormat = UIGraphicsPDFRendererFormat()
        pdfFormat.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: pdfFormat)
        let pdfData = renderer.pdfData { (context) in
            context.beginPage()
            
            // Define the starting position for the content
            var currentY: CGFloat = 50
            
            var x_logo: CGFloat = 50
            var y_logo: CGFloat = 50
            if en {
                x_logo = pageRect.width - 100
//                y_logo =
            }
            
            let logoImage = UIImage(data: AppManager.shared.getLogoImage())
            let logoRect = CGRect(x: x_logo, y: y_logo, width: 50, height: 50)  // Adjust the size and position as needed
            logoImage?.draw(in: logoRect)
            
            // Title
            let title = "Receipt No.\(receipt.myID)"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .paragraphStyle: {
                    let paragraphStyle = NSMutableParagraphStyle()
                    if en {
                        paragraphStyle.alignment = .left
                    }
                    else {
                        paragraphStyle.alignment = .right
                    }
                    return paragraphStyle
                }()
            ]
            let textRect = CGRect(x: 50, y: currentY, width: 512, height: 50)
            title.draw(in: textRect, withAttributes: titleAttributes)
            
            currentY += 50
            
            let DocumentDateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .paragraphStyle: {
                    let paragraphStyle = NSMutableParagraphStyle()
                    if en {
                        paragraphStyle.alignment = .left
                    }
                    else {
                        paragraphStyle.alignment = .right
                    }
                    return paragraphStyle
                }()
            ]
            _ = CGRect(x: 50, y: currentY, width: 512, height: 20)
            let DocumentDateText = "Date Generated:\(receipt.dateGenerated)" // choose different date
            DocumentDateText.draw(in: CGRect(x: 50, y: currentY, width: 512, height: 20), withAttributes: DocumentDateAttributes)
            
            currentY += 50
            
            
            // Draw contact details
            let contactHeaderAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .paragraphStyle: {
                    let paragraphStyle = NSMutableParagraphStyle()
                    if en {
                        paragraphStyle.alignment = .left
                    }
                    else {
                        paragraphStyle.alignment = .right
                    }
                    return paragraphStyle
                }()
            ]
            let contactHeaderRect = CGRect(x: 50, y: currentY, width: 512, height: 25)
            
            let contactHeaderText = "Customer Details"
            contactHeaderText.draw(in: contactHeaderRect, withAttributes: contactHeaderAttributes)
            
            // Update the Y position
            currentY += 25
            
            let contactDetailsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .paragraphStyle: {
                    let paragraphStyle = NSMutableParagraphStyle()
                    if en {
                        paragraphStyle.alignment = .left
                    }
                    else {
                        paragraphStyle.alignment = .right
                    }
                    return paragraphStyle
                }()
            ]
            let contactDetailsRect = CGRect(x: 50, y: currentY, width: 512, height: 20)
            let contactDetailsText =
            "שם: \(order.customer.name)\n"
            contactDetailsText.draw(in: contactDetailsRect, withAttributes: contactDetailsAttributes)
            
            currentY += 20
            
            let phoneNumberText = "מס׳ טלפון: \(order.customer.phoneNumber)"
            phoneNumberText.draw(in: CGRect(x: 50, y: currentY, width: 512, height: 20), withAttributes: contactDetailsAttributes)
            
            currentY += 50
            
            
            // Draw a table header
            let orderHeaderAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .paragraphStyle: {
                    let paragraphStyle = NSMutableParagraphStyle()
                    if en {
                        paragraphStyle.alignment = .left
                    }
                    else {
                        paragraphStyle.alignment = .right
                    }
                    return paragraphStyle
                }()
            ]
            let orderHeaderRect = CGRect(x: 50, y: currentY, width: 512, height: 25)
            let orderHeaderText = "Order Details"
            orderHeaderText.draw(in: orderHeaderRect, withAttributes: orderHeaderAttributes)
            
            // Update the Y position
            currentY += 25
            
            // Draw table headers
            let columnHeaderAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .paragraphStyle: {
                    let paragraphStyle = NSMutableParagraphStyle()
                    if en {
                        paragraphStyle.alignment = .left
                    }
                    else {
                        paragraphStyle.alignment = .right
                    }
                    return paragraphStyle
                }()
            ]
            let columnHeaderRect = CGRect(x: 262, y: currentY, width: 200, height: 20)
            let columnHeaderText = "Item"
            columnHeaderText.draw(in: columnHeaderRect, withAttributes: columnHeaderAttributes)
            
            let quantityColumnRect = CGRect(x: 462, y: currentY, width: 100, height: 20)
            let quantityColumnText = "Quantity"
            quantityColumnText.draw(in: quantityColumnRect, withAttributes: columnHeaderAttributes)
            
            //            let priceColumnRect = CGRect(x: 350, y: currentY, width: 150, height: 20)
            //            let priceColumnText = "Price"
            //            priceColumnText.draw(in: priceColumnRect, withAttributes: columnHeaderAttributes)
            
            // Update the Y position
            currentY += 20
            
            // Draw the order details in a tabular form
            let cellAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .paragraphStyle: {
                    let paragraphStyle = NSMutableParagraphStyle()
                    if en {
                        paragraphStyle.alignment = .left
                    }
                    else {
                        paragraphStyle.alignment = .right
                    }
                    return paragraphStyle
                }()
            ]
            
            for dessert in order.desserts {
                let dessertNameRect = CGRect(x: 262, y: currentY, width: 200, height: 20)
                dessert.inventoryItem.name.draw(in: dessertNameRect, withAttributes: cellAttributes)
                
                let quantityRect = CGRect(x: 462, y: currentY, width: 100, height: 20)
                String(dessert.quantity).draw(in: quantityRect, withAttributes: cellAttributes)
                
                //                let priceRect = CGRect(x: 350, y: currentY, width: 150, height: 20)
                //                String(format: "₪%.2f", dessert.price * Double(dessert.quantity)).draw(in: priceRect, withAttributes: cellAttributes)
                
                // Update the Y position
                currentY += 20
            }
            
            // Draw the total price
            let totalPriceAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .paragraphStyle: {
                    let paragraphStyle = NSMutableParagraphStyle()
                    if en {
                        paragraphStyle.alignment = .left
                    }
                    else {
                        paragraphStyle.alignment = .right
                    }
                    return paragraphStyle
                }()
            ]
            let totalPriceRect = CGRect(x: 50, y: currentY, width: 512, height: 25)
            
            let totalPriceText = "Total price: $\(order.totalPrice)"
            totalPriceText.draw(in: totalPriceRect, withAttributes: totalPriceAttributes)
            
            // Update the Y position
            currentY += 50
            
            
            //            if order.delivery.cost != 0 {
            //                let deliveryCostText = "Delivery Cost: \(order.delivery.cost)"
            //                deliveryCostText.draw(in: CGRect(x: 50, y: currentY, width: 512, height: 20), withAttributes: contactDetailsAttributes)
            //
            //                currentY += 20
            //            }
            
            // Draw the payment details
            let paymentHeaderAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .paragraphStyle: {
                    let paragraphStyle = NSMutableParagraphStyle()
                    if en {
                        paragraphStyle.alignment = .left
                    }
                    else {
                        paragraphStyle.alignment = .right
                    }
                    return paragraphStyle
                }()
            ]
            let paymentHeaderRect = CGRect(x: 50, y: currentY, width: 512, height: 25)
            
            let paymentHeaderText = "Payment Details"
            paymentHeaderText.draw(in: paymentHeaderRect, withAttributes: paymentHeaderAttributes)
            
            // Update the Y position
            currentY += 25
            
            let paymentDetailsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .paragraphStyle: {
                    let paragraphStyle = NSMutableParagraphStyle()
                    if en {
                        paragraphStyle.alignment = .left
                    }
                    else {
                        paragraphStyle.alignment = .right
                    }
                    return paragraphStyle
                }()
            ]
            let paymentDetailsRect = CGRect(x: 50, y: currentY, width: 512, height: 20)
            
            let paymentMethodText = "Payment Method: \(String(describing: receipt.paymentMethod))"
            paymentMethodText.draw(in: paymentDetailsRect, withAttributes: paymentDetailsAttributes)
            
            // Update the Y position for the next detail
            currentY += 20
            
            let paymentDateText = "Payment Date: \(dateFormatter.string(from: receipt.paymentDate)))"
            paymentDateText.draw(in: CGRect(x: 50, y: currentY, width: 512, height: 20), withAttributes: paymentDetailsAttributes)
            
            // Digital or image signature
            var x_sign = pageRect.width - 150
            var y_sign = pageRect.height - 150
            if en {
                x_sign = 50
//                y_sign =
            }
            let signatureImage = UIImage(data: AppManager.shared.getSignatureImage())
               let signatureRect = CGRect(x: x_sign, y: y_sign, width: 50, height: 50)
               signatureImage?.draw(in: signatureRect)
        }
        return pdfData
    }   
    
}

struct GeneratedReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        
        let sampleItem = InventoryItem(name: "Chocolate cake",
                                       itemPrice: 20,
                                       itemQuantity: 20,
                                       size: "20",
                                       AdditionDate: Date(),
                                       itemNotes: ""
                                       )
        
        let sampleItem_ = InventoryItem(name: "Raspberry pie",
                                       itemPrice: 120,
                                       itemQuantity: 3,
                                        size: "",
                                        AdditionDate: Date(),
                                       itemNotes: ""
                                        )
        
        let sampleOrder = Order(
            orderID: "1234",
            customer: Customer(name: "John Doe", phoneNumber: "0546768900"),
            desserts: [OrderItem(inventoryItem: sampleItem, quantity: 2,price: sampleItem.itemPrice),
                       OrderItem(inventoryItem: sampleItem_, quantity: 1, price: sampleItem_.itemPrice)],
            orderDate: Date(),
            delivery: Delivery(address: "yefe nof 18, peduel", cost: 10),
            notes: "",
            allergies: "",
            isDelivered: false,
            isPaid: false
            
//            receipt: Receipt(id: UUID().uuidString, myID: 101, orderID: "1234", pdfData: Data(), dateGenerated: Date(), paymentMethod: "bit", paymentDate: Date())
            

            
        )
        
        return GeneratedReceiptView(orderManager: OrderManager.shared, order: sampleOrder, isPresented: .constant(false))
            .previewLayout(.sizeThatFits)
                        .padding()
    }
}
