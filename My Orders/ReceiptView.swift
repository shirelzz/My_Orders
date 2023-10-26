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
    
    let order: DessertOrder
    
    @Binding var isPresented: Bool
    @State private var pdfData: Data?
    @State private var showConfirmationAlert = false
    //    @ObservedObject var orderManager: OrderManager
    @State private var selectedPaymentMethod = ""
    @State private var selectedPaymentDate: Date = Date()
    
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        
        VStack(alignment: .trailing, spacing: 10) {
            
            Text("קבלה")
                .font(.title)
                .bold()
                .padding(.bottom, 20)
            
            HStack{
                Text("עבור:")
                    .bold()
                Text(order.customer.name)
            }
            .environment(\.layoutDirection, .rightToLeft)

            
            HStack{
                Text("תאריך יצירת המסמך:")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text(dateFormatter.string(from: Date()))
                    .padding(.bottom)
            }
            .environment(\.layoutDirection, .rightToLeft)

            
            Section(header:
                        Text("פרטי הזמנה:")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top)
            ) {
                List(order.desserts, id: \.dessertName) { dessert in
                    HStack {
                        Text("\(dessert.dessertName)")
                        Spacer()
                        Text("Q: \(dessert.quantity)")
                        //                    Text("₪\(dessert.price, specifier: "%.2f")")
                    }
                }
            }
            
            HStack{
                Text("₪")
                Text(String(format: "%.2f", order.totalPrice))
                Text("מחיר: ")
                    .font(.headline)

            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("אופן התשלום:")
                    .font(.headline)
                
                Picker("", selection: $selectedPaymentMethod) {
                    Text("Paybox")
                    Text("Bit")
                    Text("Bank transfer")
                    Text("Cash")
//                    Text("העברה בנקאית")
//                    Text("מזומן")
                }
                .pickerStyle(DefaultPickerStyle())
                
                Text("Selected Payment Method: \(selectedPaymentMethod)")
            }
            .environment(\.layoutDirection, .rightToLeft)




            
            HStack {
                Text("מועד התשלום:ֿ")
                    .font(.headline)
                Spacer()
                
                DatePicker("", selection: $selectedPaymentDate, displayedComponents: .date)
                    .datePickerStyle(DefaultDatePickerStyle())
                
                
            }
            .environment(\.layoutDirection, .rightToLeft)
            
            
            
            
            if !OrderManager.shared.receiptExists(forOrderID: order.orderID) {
                Button("Generate PDF Receipt") {
                    showConfirmationAlert = true // Show the confirmation alert
                }
                .padding(.top, 20)
                .alert(isPresented: $showConfirmationAlert) {
                    Alert(
                        title: Text("Generate Receipt"),
                        message: Text("Are you sure you want to generate this receipt?"),
                        primaryButton: .default(Text("Generate")) {
                            // User confirmed, generate the receipt
                            generatePDF()
                        },
                        secondaryButton: .cancel(Text("Cancel")) {
                            // User canceled, dismiss the alert
                        }
                    )
                }
            }
            
            
            if OrderManager.shared.receiptExists(forOrderID: order.orderID) {
                Button("Share PDF Receipt") {
                    guard let pdfData = self.pdfData else {
                        return
                    }
                    
                    // Get the active window scene
                    if let windowScene = UIApplication.shared.connectedScenes
                        .first(where: { $0 is UIWindowScene }) as? UIWindowScene {
                        
                        // Present the PDF sharing view
                        let pdfShareView = SharePDFView(pdfData: pdfData)
                        let hostingController = UIHostingController(rootView: pdfShareView)
                        
                        if let rootViewController = windowScene.windows.first?.rootViewController {
                            rootViewController.present(hostingController, animated: true, completion: nil)
                        }
                    }
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
                    orderID: order.orderID,
                    pdfData: pdfData,
                    dateGenerated: Date(),
                    paymentMethod: selectedPaymentMethod ,
                    paymentDate: selectedPaymentDate
                )
            
            // Save the receipt and mark the order ID as generated
            OrderManager.shared.addReceipt(receipt: receipt)
            
            
            isPresented = true
            
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: documentDirectory.path)
                    print("Files in document directory: \(files)")
                } catch {
                    print("Error listing files in document directory: \(error.localizedDescription)")
                }
            }

            
        } catch {
            print("Error saving PDF: \(error.localizedDescription)")
        }
    }
    
    
    
    private func drawPDF() -> Data {
        // Create a PDF context
        let pdfMetaData = [
            kCGPDFContextCreator: "My Orders",
            kCGPDFContextAuthor: "Shirel Turgeman"
        ]
        let pdfFormat = UIGraphicsPDFRendererFormat()
        pdfFormat.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter size
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: pdfFormat)
        let pdfData = renderer.pdfData { (context) in
            context.beginPage()
            
            // Define the starting position for the content
            var currentY: CGFloat = 50
            
            // Title
            let title = "Receipt for Order \(order.orderID)"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24)
            ]
            let textRect = CGRect(x: 50, y: currentY, width: 512, height: 50)
            title.draw(in: textRect, withAttributes: titleAttributes)
            
            currentY += 50
            
            // Draw contact details

            let contactHeaderAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 14)
                    ]
                    let contactHeaderRect = CGRect(x: 50, y: currentY, width: 512, height: 25)

                    let contactHeaderText = "Contact Details"
                    contactHeaderText.draw(in: contactHeaderRect, withAttributes: contactHeaderAttributes)

                    // Update the Y position
                    currentY += 25
            
            let contactDetailsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]
            let contactDetailsRect = CGRect(x: 50, y: currentY, width: 512, height: 20)
            let contactDetailsText =
                "Name: \(order.customer.name)\n"
            contactDetailsText.draw(in: contactDetailsRect, withAttributes: contactDetailsAttributes)
            
            currentY += 20

            let phoneNumberText = "Phone Number: \(order.customer.phoneNumber)"
            phoneNumberText.draw(in: CGRect(x: 50, y: currentY, width: 512, height: 20), withAttributes: contactDetailsAttributes)
            
            currentY += 50

            
            // Draw a table header
            let orderHeaderAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14)
            ]
            let orderHeaderRect = CGRect(x: 50, y: currentY, width: 512, height: 25)
            let orderHeaderText = "Order Details"
            orderHeaderText.draw(in: orderHeaderRect, withAttributes: orderHeaderAttributes)

            // Update the Y position
            currentY += 25

            // Draw table headers
            let columnHeaderAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 12)
            ]
            let columnHeaderRect = CGRect(x: 50, y: currentY, width: 200, height: 20)
            let columnHeaderText = "Dessert Name"
            columnHeaderText.draw(in: columnHeaderRect, withAttributes: columnHeaderAttributes)

            let quantityColumnRect = CGRect(x: 250, y: currentY, width: 100, height: 20)
            let quantityColumnText = "Quantity"
            quantityColumnText.draw(in: quantityColumnRect, withAttributes: columnHeaderAttributes)

//            let priceColumnRect = CGRect(x: 350, y: currentY, width: 150, height: 20)
//            let priceColumnText = "Price"
//            priceColumnText.draw(in: priceColumnRect, withAttributes: columnHeaderAttributes)

            // Update the Y position
            currentY += 20

            // Draw the order details in a tabular form
            let cellAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]

            for dessert in order.desserts {
                let dessertNameRect = CGRect(x: 50, y: currentY, width: 200, height: 20)
                dessert.dessertName.draw(in: dessertNameRect, withAttributes: cellAttributes)

                let quantityRect = CGRect(x: 250, y: currentY, width: 100, height: 20)
                String(dessert.quantity).draw(in: quantityRect, withAttributes: cellAttributes)

//                let priceRect = CGRect(x: 350, y: currentY, width: 150, height: 20)
//                String(format: "₪%.2f", dessert.price * Double(dessert.quantity)).draw(in: priceRect, withAttributes: cellAttributes)

                // Update the Y position
                currentY += 20
            }
            
            // Draw the total price
                    let totalPriceAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 14)
                    ]
                    let totalPriceRect = CGRect(x: 50, y: currentY, width: 512, height: 25)

                    let totalPriceText = "Total Price: ₪\(order.totalPrice)"
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
                        .font: UIFont.boldSystemFont(ofSize: 14)
                    ]
                    let paymentHeaderRect = CGRect(x: 50, y: currentY, width: 512, height: 25)

                    let paymentHeaderText = "Payment Details"
                    paymentHeaderText.draw(in: paymentHeaderRect, withAttributes: paymentHeaderAttributes)

                    // Update the Y position
                    currentY += 25
            
            let paymentDetailsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]
            let paymentDetailsRect = CGRect(x: 50, y: currentY, width: 512, height: 20)

            let paymentMethodText = "Payment Method: \(selectedPaymentMethod)"
            paymentMethodText.draw(in: paymentDetailsRect, withAttributes: paymentDetailsAttributes)

            // Update the Y position for the next detail
            currentY += 20

            let paymentDateText = "Payment Date: \(dateFormatter.string(from: selectedPaymentDate))"
            paymentDateText.draw(in: CGRect(x: 50, y: currentY, width: 512, height: 20), withAttributes: paymentDetailsAttributes)
            
            // Digital signature
        }
        
        return pdfData
    }


}

struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleOrder = DessertOrder(
            orderID: "123",
            customer: Customer(name: "John Doe", phoneNumber: 0546768900),
            desserts: [Dessert(dessertName: "Chocolate Cake", quantity: 2, price: 10.0),
                       Dessert(dessertName: "raspberry pie", quantity: 1, price: 120.0)],
            orderDate: Date(),
            delivery: Delivery(address: "yefe nof 18, peduel", cost: 10),
            notes: "",
            allergies: "",
            isCompleted: false
        )
        
        
        return ReceiptView(order: sampleOrder, isPresented: .constant(false))
    }
}

