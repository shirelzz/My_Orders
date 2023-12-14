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
    @ObservedObject var languageManager: LanguageManager
    
    @State var order: Order
    @Binding var isPresented: Bool
    @State private var pdfData: Data?
    @State private var showConfirmationAlert = false
    @State private var selectedPaymentMethod = "Paybox"
    @State private var selectedPaymentDate: Date = Date()
    @State private var showSuccessMessage = false
    @State private var lastReceipttID = OrderManager.shared.getLastReceiptID()
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
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
                Text(dateFormatter.string(from: Date()))
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
            .padding(.leading)

            
            HStack(alignment: .center, spacing: 160) {
                Text("Payment method:")
                    .font(.headline)
                
                Picker(selection: $selectedPaymentMethod, label: Text("Payment Method")) {
                    Text("Paybox").tag("Paybox")
                    Text("Bit").tag("Bit")
                    Text("Bank transfer").tag("Bank transfer")
                    Text("Cash").tag("Cash")
                }
                .pickerStyle(DefaultPickerStyle())
                .scaledToFit()
                
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
                        message: Text("Are you sure you want to generate this receipt?"),
                        primaryButton: .default(Text("Generate")) {
                            generatePDF()
                            if showSuccessMessage {
                                Toast.showToast(message: "Receipt generated successfully")
                            }
                            
                        },
                        secondaryButton: .cancel(Text("Cancel")) {
                        }
                    )
                }
            }
            
            if OrderManager.shared.receiptExists(forOrderID: order.orderID) {
                Button("Share PDF Receipt") {
                    pdfData = drawPDF()
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
                }
                .padding(.top, 20)
            }
            
        }
        .padding()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }
    
    private func generatePDF() {
        // Check if a receipt with the same order ID already exists
        if OrderManager.shared.receiptExists(forOrderID: order.orderID) {
            isPresented = true
            return
        }
        
        let pdfData = drawPDF()
        
        // Specify the file URL where you want to save the PDF
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("receipt.pdf") else {
            return
        }
        
        // Save the PDF to the file URL
        do {
            try pdfData.write(to: fileURL)
            self.pdfData = pdfData
            
            // Log the file path
            print("PDF file saved to: \(fileURL)")
            
            // Create a Receipt instance
            let receipt = Receipt(
                id: UUID().uuidString,
                myID: lastReceipttID + 1,
                orderID: order.orderID,
                pdfData: pdfData, //self.pdfData
                dateGenerated: Date(),
                paymentMethod: selectedPaymentMethod ,
                paymentDate: selectedPaymentDate
            )
            
            if let updatedOrder = OrderManager.shared.assignReceiptToOrder(receipt: receipt, toOrderWithID: order.orderID) {
                // Save the receipt and mark the order ID as generated
                OrderManager.shared.addReceipt(receipt: receipt)
                
                // Print the order
                //                print("receiptview")
                //                OrderManager.shared.printOrder(order: updatedOrder)
            }
            
            isPresented = true
            
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: documentDirectory.path)
                    print("Files in document directory: \(files)")
                } catch {
                    print("Error listing files in document directory: \(error.localizedDescription)")
                }
            }
            
            showSuccessMessage = true
            
            
        } catch {
            print("Error saving PDF: \(error.localizedDescription)")
        }
    }
    
    
    
    private func drawPDF() -> Data {
        
        let receipt_ = OrderManager.shared.getReceipt(forOrderID: order.orderID)
        let en = LanguageManager.shared.getCurrentLanguage() == "english"
        let he = LanguageManager.shared.getCurrentLanguage() == "hebrew"
        let receiptExists = OrderManager.shared.receiptExists(forOrderID: order.orderID)
        
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
            
            let logoImage = UIImage(data: AppManager.shared.getLogoImage())
            let logoRect = CGRect(x: 50, y: 50, width: 50, height: 50)  // Adjust the size and position as needed
            logoImage?.draw(in: logoRect)
            
            // Title
//            var title = ""
//            if (receiptExists){
//                title = "Receipt No. \(receipt_.myID)"
//            }
//            else{
//                title = "Receipt No. \(lastReceipttID + 1)"
//            }
                        var title = ""
                        if (receiptExists && en){
                            title = "Receipt No. \(receipt_.myID)"
            
                        }
                        else if (receiptExists && he ){
                            title = "קבלה מספר \(receipt_.myID)"
                        }
                        else if (!receiptExists && en){
                            title = "Receipt No. \(lastReceipttID + 1)"
                        }
                        else {
                            title = "קבלה מספר \(lastReceipttID + 1)"
                        }
            
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
            
            var DocumentDateText = ""
//            if (receiptExists){
//                DocumentDateText = "Date created:\(receipt_.dateGenerated.formatted())"
//            }
//            else if (receiptExists){
//                DocumentDateText = "Date created:\(Date().formatted())"
//            }
            
                        if (receiptExists && en){
                            DocumentDateText = "Date created: \(receipt_.dateGenerated.formatted())"
                        }
                        else if (receiptExists && he){
                            DocumentDateText = "תאריך יצירת המסמך: \(receipt_.dateGenerated.formatted())"
                        }
                        else if (!receiptExists && en){
                            DocumentDateText = "Date created: \(Date().formatted())"
                        }
                        else{
                            DocumentDateText = "תאריך יצירת המסמך: \(Date().formatted())"
                        }
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
            
            
            var contactHeaderText = ""
            if en {
                contactHeaderText = "Customer Details"
            }
            else {
                contactHeaderText = "פרטי הלקוח"
            }
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
            
            var contactDetailsText = ""
            if en {
                contactDetailsText = "Name: \(order.customer.name)\n"
            }
            else {
                contactDetailsText = "שם: \(order.customer.name)\n"
            }
            contactDetailsText.draw(in: contactDetailsRect, withAttributes: contactDetailsAttributes)
            
            currentY += 20
            
            var phoneNumberText = ""
            if en {
                phoneNumberText = "Phone Number: \(order.customer.phoneNumber)"
            }
            else {
                phoneNumberText = "מס׳ טלפון: \(order.customer.phoneNumber)"
            }
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
            
            var orderHeaderText = ""
            if en {
                orderHeaderText = "Order Details"
            }
            else {
                orderHeaderText = "פרטי הזמנה"
            }
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
            
            var columnHeaderText = ""
            if en {
                columnHeaderText = "Item"
            }
            else {
                columnHeaderText = "מוצר"
            }
            columnHeaderText.draw(in: columnHeaderRect, withAttributes: columnHeaderAttributes)
            
            let quantityColumnRect = CGRect(x: 462, y: currentY, width: 100, height: 20)
            
            var quantityColumnText = ""
            if en {
                quantityColumnText = "Quantity"
            }
            else {
                quantityColumnText = "כמות"
            }
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
            
            
            var totalPriceText = ""
            if en {
                totalPriceText = "Total Cost: $\(order.totalPrice)"
            }
            else {
                totalPriceText = "עלות כוללת: ₪\(order.totalPrice)"
            }
//            let totalPriceText = "Total Cost: $\(order.totalPrice)"
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
            
            var paymentHeaderText = ""
            if en {
                paymentHeaderText = "Payment Details"
            }
            else {
                paymentHeaderText = "פרטי התשלום"
            }
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
            
            var paymentMethodText = ""
            if en {
                paymentMethodText = "Payment Method \(selectedPaymentMethod)"
            }
            else {
                paymentMethodText = "שיטת התשלום: \(selectedPaymentMethod)"
            }
//            let paymentMethodText = "Payment Method \(selectedPaymentMethod)"
            paymentMethodText.draw(in: paymentDetailsRect, withAttributes: paymentDetailsAttributes)
            
            // Update the Y position for the next detail
            currentY += 20
            
            var paymentDateText = ""
            if en {
                paymentDateText = "Payment Date: \(dateFormatter.string(from: receipt_.paymentDate))"
            }
            else {
                paymentDateText = "מועד התשלום: \(dateFormatter.string(from: receipt_.paymentDate))"
            }
//            let paymentDateText = "Payment Date: \(dateFormatter.string(from: receipt_.paymentDate))"
            paymentDateText.draw(in: CGRect(x: 50, y: currentY, width: 512, height: 20), withAttributes: paymentDetailsAttributes)
            
            //  signature
            
            let signatureImage = UIImage(data: AppManager.shared.getSignatureImage())
               let signatureRect = CGRect(x: pageRect.width - 150, y: pageRect.height - 150, width: 50, height: 50)  // Adjust the size and position as needed
               signatureImage?.draw(in: signatureRect)
        }
        
        return pdfData
    }
    
    
}

struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        
        let sampleItem = InventoryItem(name: "Chocolate cake",
                                       itemPrice: 20,
                                       itemQuantity: 20,
                                       size: "",
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
            desserts: [Dessert(inventoryItem: sampleItem, quantity: 2,price: sampleItem.itemPrice),
                       Dessert(inventoryItem: sampleItem_, quantity: 1, price: sampleItem_.itemPrice)],
            orderDate: Date(),
            delivery: Delivery(address: "yefe nof 18, peduel", cost: 10),
            notes: "",
            allergies: "",
            isDelivered: false,
            isPaid: false,
            
            receipt: nil
            

            
        )
        
        return ReceiptView(orderManager: OrderManager.shared, languageManager: LanguageManager.shared, order: sampleOrder, isPresented: .constant(false))
            .previewLayout(.sizeThatFits)
                        .padding()
    }
}

