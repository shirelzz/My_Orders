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
    
    let order: DessertOrder
    
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
                
        VStack(alignment: .trailing, spacing: 10) {
            
            Text("קבלה")
                .font(.title)
                .bold()
                .padding(.bottom, 20)
            
            Text("קבלה מספר \(order.receipt?.myID ?? 0)")

            HStack{
                Text("תאריך יצירת המסמך:")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                if let dateGenerated = order.receipt?.dateGenerated {
                    Text("\(dateFormatter.string(from: dateGenerated))").padding(.bottom)
                } else {
                    // Handle the case when dateGenerated is nil
                    Text("N/A").padding(.bottom)
                }
                
            }
            .environment(\.layoutDirection, .rightToLeft)
            
            HStack{
                Text("עבור:")
                    .bold()
                Text(order.customer.name)
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
                        // Text("₪\(dessert.price, specifier: "%.2f")")
                    }
                }
            }
            
            HStack{
                Text("₪")
                Text(String(format: "%.2f", order.totalPrice))
                Text("מחיר: ")
                    .font(.headline)
                
            }
            
            HStack(alignment: .center, spacing: 5) {
                
                Text("אופן התשלום:")
                    .font(.headline)
                Text("\(order.receipt?.paymentMethod ?? "")")
            }
            .environment(\.layoutDirection, .rightToLeft)
            
            HStack(alignment: .center, spacing: 5){
                Text("מועד התשלום:")
                    .font(.headline)
                Text("\(dateFormatter.string(from: order.receipt?.paymentDate ?? Date()))")
            }
            .environment(\.layoutDirection, .rightToLeft)
            
            
            if !OrderManager.shared.receiptExists(forOrderID: order.orderID) {
                Button("Share PDF Receipt") {
                    generatePDF()
                    
                    guard let pdfData = self.pdfData else {
                        return
                    }
                    
                    if let windowScene = UIApplication.shared.connectedScenes
                        .first(where: { $0 is UIWindowScene }) as? UIWindowScene {
                        
                        let pdfShareView = SharePDFView(pdfData: pdfData)
                        let hostingController = UIHostingController(rootView: pdfShareView)
                        
                        if let rootViewController = windowScene.windows.first?.rootViewController {
                            rootViewController.present(hostingController, animated: true, completion: nil)
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
            
            // Title
            let title = "קבלה מספר \(order.receipt?.myID ?? 0)"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .paragraphStyle: {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .right
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
                    paragraphStyle.alignment = .right
                    return paragraphStyle
                }()
            ]
            _ = CGRect(x: 50, y: currentY, width: 512, height: 20)
            let DocumentDateText = "תאריך יצירת המסמך: \(order.receipt?.dateGenerated ?? Date())" // choose different date
            DocumentDateText.draw(in: CGRect(x: 50, y: currentY, width: 512, height: 20), withAttributes: DocumentDateAttributes)
            
            currentY += 50
            
            
            // Draw contact details
            let contactHeaderAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .paragraphStyle: {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .right
                    return paragraphStyle
                }()
            ]
            let contactHeaderRect = CGRect(x: 50, y: currentY, width: 512, height: 25)
            
            let contactHeaderText = "פרטי הלקוח"
            contactHeaderText.draw(in: contactHeaderRect, withAttributes: contactHeaderAttributes)
            
            // Update the Y position
            currentY += 25
            
            let contactDetailsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .paragraphStyle: {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .right
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
                    paragraphStyle.alignment = .right
                    return paragraphStyle
                }()
            ]
            let orderHeaderRect = CGRect(x: 50, y: currentY, width: 512, height: 25)
            let orderHeaderText = "פרטי הזמנה"
            orderHeaderText.draw(in: orderHeaderRect, withAttributes: orderHeaderAttributes)
            
            // Update the Y position
            currentY += 25
            
            // Draw table headers
            let columnHeaderAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .paragraphStyle: {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .right
                    return paragraphStyle
                }()
            ]
            let columnHeaderRect = CGRect(x: 262, y: currentY, width: 200, height: 20)
            let columnHeaderText = "מוצר"
            columnHeaderText.draw(in: columnHeaderRect, withAttributes: columnHeaderAttributes)
            
            let quantityColumnRect = CGRect(x: 462, y: currentY, width: 100, height: 20)
            let quantityColumnText = "כמות"
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
                    paragraphStyle.alignment = .right
                    return paragraphStyle
                }()
            ]
            
            for dessert in order.desserts {
                let dessertNameRect = CGRect(x: 262, y: currentY, width: 200, height: 20)
                dessert.dessertName.draw(in: dessertNameRect, withAttributes: cellAttributes)
                
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
                    paragraphStyle.alignment = .right
                    return paragraphStyle
                }()
            ]
            let totalPriceRect = CGRect(x: 50, y: currentY, width: 512, height: 25)
            
            let totalPriceText = "עלות כוללת: ₪\(order.totalPrice)"
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
                    paragraphStyle.alignment = .right
                    return paragraphStyle
                }()
            ]
            let paymentHeaderRect = CGRect(x: 50, y: currentY, width: 512, height: 25)
            
            let paymentHeaderText = "פרטי התשלום"
            paymentHeaderText.draw(in: paymentHeaderRect, withAttributes: paymentHeaderAttributes)
            
            // Update the Y position
            currentY += 25
            
            let paymentDetailsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .paragraphStyle: {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .right
                    return paragraphStyle
                }()
            ]
            let paymentDetailsRect = CGRect(x: 50, y: currentY, width: 512, height: 20)
            
            let paymentMethodText = "שיטת התשלום: \(String(describing: order.receipt?.paymentMethod))"
            paymentMethodText.draw(in: paymentDetailsRect, withAttributes: paymentDetailsAttributes)
            
            // Update the Y position for the next detail
            currentY += 20
            
            let paymentDateText = "מועד התשלום: \(dateFormatter.string(from: order.receipt?.paymentDate ?? Date()))"
            paymentDateText.draw(in: CGRect(x: 50, y: currentY, width: 512, height: 20), withAttributes: paymentDetailsAttributes)
            
            // Digital or image signature
        }
        return pdfData
    }
    
   
    
    
}

struct GeneratedReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        
        let sampleOrder = DessertOrder(
            orderID: "1234",
            customer: Customer(name: "John Doe", phoneNumber: 0546768900),
            desserts: [Dessert(dessertName: "Chocolate Cake", quantity: 2, price: 10.0),
                       Dessert(dessertName: "raspberry pie", quantity: 1, price: 120.0)],
            orderDate: Date(),
            delivery: Delivery(address: "yefe nof 18, peduel", cost: 10),
            notes: "",
            allergies: "",
            isCompleted: false,
            isPaid: false,
            
            receipt: Receipt(myID: 101, orderID: "1234", pdfData: Data(), dateGenerated: Date(), paymentMethod: "bit", paymentDate: Date())
            

            
        )
        
        return GeneratedReceiptView(order: sampleOrder, isPresented: .constant(false))
            .previewLayout(.sizeThatFits)
                        .padding()
    }
}
