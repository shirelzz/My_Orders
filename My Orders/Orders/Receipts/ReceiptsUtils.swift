//
//  ReceiptsUtils.swift
//  My Orders
//
//  Created by שיראל זכריה on 17/12/2023.
//

import Foundation
import PDFKit
import UIKit
import ZipArchive

class ReceiptUtils {
    
    
    
    static func drawPDF(for order: Order) -> Data {
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter
        }
        
            let receipt_ = OrderManager.shared.getReceipt(forOrderID: order.orderID)
            let receiptExists = OrderManager.shared.receiptExists(forOrderID: order.orderID)
            
            //        let en = LanguageManager.shared.getCurrentLanguage() == "english"
            //        let he = LanguageManager.shared.getCurrentLanguage() == "hebrew"
            
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
    //            var title = ""
    //            if (receiptExists){
    //                title = "Receipt No. \(receipt_.myID)"
    //            }
    //            else{
    //                title = "Receipt No. \(lastReceipttID + 1)"
    //            }
//                            var title = ""
//                            if (receiptExists && en){
//                                title = "Receipt No. \(receipt_.myID)"
//                
//                            }
//                            else if (receiptExists && he ){
//                                title = "קבלה מספר \(receipt_.myID)"
//                            }
//                            else if (!receiptExists && en){
//                                title = "Receipt No. \(lastReceipttID + 1)"
//                            }
//                            else {
//                                title = "קבלה מספר \(lastReceipttID + 1)"
//                            }
                
               var title = ""
                if en{
                    title = "Receipt No. \(receipt_.myID)"
                }
                else {
                    title = "קבלה מספר \(receipt_.myID)"
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
                    paymentMethodText = "Payment Method \(receipt_.paymentMethod)"
                }
                else {
                    paymentMethodText = "שיטת התשלום: \(receipt_.paymentMethod)"
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
                var x_sign = pageRect.width - 150
                var y_sign = pageRect.height - 150
                if en {
                    x_sign = 50
    //                y_sign =
                }
                let signatureImage = UIImage(data: AppManager.shared.getSignatureImage())
                   let signatureRect = CGRect(x: x_sign, y: y_sign, width: 50, height: 50)  // Adjust the size and position as needed
                   signatureImage?.draw(in: signatureRect)
            }
            
            return pdfData
        
    }

//    static func generateReceipt(for order: Order) -> Receipt {
//        
//    }

    static func exportReceiptAsPDF(orderManager: OrderManager, receipt: Receipt, selectedYear: Int) {
        // Filter receipts by the selected year
        let filteredReceipts = orderManager.receipts.filter { receipt in
            let receiptYear = Calendar.current.component(.year, from: receipt.dateGenerated)
            return receiptYear == selectedYear
        }

        // Create a temporary directory to store individual PDFs
        let tempDirectory = FileManager.default.temporaryDirectory

        // Create a zip file name for the exported file
        let zipFileName = "Receipts-\(selectedYear).zip"
        let zipFileURL = tempDirectory.appendingPathComponent(zipFileName)

        // Create a PDF for each receipt and save it in the temporary directory
        for (index, receipt) in filteredReceipts.enumerated() {
            let order = orderManager.getOrder(orderID: receipt.orderID)
            
            if order.orderID != "" {
                    let pdfData = ReceiptUtils.drawPDF(for: order)
                    let pdfFileName = "Receipt-\(index + 1).pdf"
                    let pdfFileURL = tempDirectory.appendingPathComponent(pdfFileName)
                    
                    do {
                        try pdfData.write(to: pdfFileURL)
                    } catch {
                        print("Error saving PDF: \(error.localizedDescription)")
                    }
            }
        }

        // Create a zip archive containing all PDFs
        SSZipArchive.createZipFile(atPath: zipFileURL.path, withContentsOfDirectory: tempDirectory.path)

        // Create a share activity view controller
        let activityViewController = UIActivityViewController(activityItems: [zipFileURL], applicationActivities: nil)

        // Present the share view controller
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        if let topViewController = window?.rootViewController {
            topViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}

