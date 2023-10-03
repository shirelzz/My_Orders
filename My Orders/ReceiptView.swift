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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Receipt")
                .font(.title)
                .bold()
                .padding(.bottom, 20)
            
            Text("Adressee: \(order.customer.name)")
            Text("Date: \(formattedDate(order.orderDate))")
            
            
            Section(header:
                        Text("Order Information")
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
            
            Text("Total Price: ₪\(order.totalPrice, specifier: "%.2f")")
            
            // Add a button to generate the PDF
            Button("Generate PDF Receipt") {
                generatePDF()
            }
            .padding(.top, 20)
            
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
            Spacer()
            
        }
        .padding()
        .onAppear {
            // Generate the PDF when the view appears
            generatePDF()
        }
//        .alert(isPresented: $isPresented) {
//            Alert(
//                title: Text("PDF Generated"),
//                message: Text("The PDF receipt has been generated."),
//                dismissButton: .default(Text("OK"))
//            )
//        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }
    
    private func generatePDF() {
        // Check if a receipt with the same order ID already exists
        if OrderManager.shared.receiptExists(forOrderID: order.orderID) {
            // A receipt for this order has already been generated
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
            
            // Create a Receipt instance
            let receipt = Receipt(orderID: order.orderID, pdfData: pdfData, dateGenerated: Date())
            
            // Save the receipt and mark the order ID as generated
            OrderManager.shared.addReceipt(receipt: receipt)
            
            isPresented = true
        } catch {
            print("Error saving PDF: \(error.localizedDescription)")
        }
    }


    
    private func drawPDF() -> Data {
        // Create a PDF context
        let pdfMetaData = [
            kCGPDFContextCreator: "My App",
            kCGPDFContextAuthor: "Your Name"
        ]
        let pdfFormat = UIGraphicsPDFRendererFormat()
        pdfFormat.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter size
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: pdfFormat)
        let pdfData = renderer.pdfData { (context) in
            context.beginPage()
            
            // Draw your content onto the PDF context here
            let text = "Receipt for Order"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24)
            ]
            let textRect = CGRect(x: 50, y: 50, width: 512, height: 50)
            text.draw(in: textRect, withAttributes: attributes)
            
            // You can draw more content as needed
            
            // Example: Drawing an image
            if let image = UIImage(named: "your-image-name") {
                let imageRect = CGRect(x: 50, y: 100, width: 100, height: 100)
                image.draw(in: imageRect)
            }
            
            // Example: Drawing text
            let orderDateText = "Order Date: \(formattedDate(order.orderDate))"
            orderDateText.draw(in: CGRect(x: 50, y: 220, width: 512, height: 50), withAttributes: attributes)
            
            // Draw other order information as needed
            
            // Save digital signature (if applicable)
        }
        
        return pdfData
    }
}

struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleOrder = DessertOrder(
            orderID: "123",
            customer: Customer(name: "John Doe", phoneNumber: 0546768900),
            desserts: [Dessert(dessertName: "Chocolate Cake", quantity: 2, price: 10.0)],
            orderDate: Date(),
            delivery: Delivery(address: "yefe nof 18, peduel", cost: 10),
            notes: "",
            allergies: "",
            isCompleted: false
        )
        
        return ReceiptView(order: sampleOrder, isPresented: .constant(false))
    }
}

