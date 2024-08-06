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
    
    static func generatePDF(order: Order, receipt: Receipt) -> Data? {
        
        if OrderManager.shared.assignReceiptToOrder(receipt: receipt, toOrderWithID: order.orderID) != nil {
            OrderManager.shared.addReceipt(receipt: receipt)
        }
        
        let pdfData = drawPDF(for: order)
        
        // Specify the file URL where you want to save the PDF
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("receipt.pdf") else {
            return nil
        }
        
        // Save the PDF to the file URL
        do {
            try pdfData.write(to: fileURL)
            
            // Log the file path
            print("PDF file saved to: \(fileURL)")
                        
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
        
        return pdfData
    }
    
    static func drawPDF(for order: Order) -> Data {
        
            let receipt_ = OrderManager.shared.getReceipt(forOrderID: order.orderID)
            let receiptExists = OrderManager.shared.receiptExists(forOrderID: order.orderID)
            
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
                let y_logo: CGFloat = 50
                if en {
                    x_logo = pageRect.width - 100
                }
                
                let logoImage = UIImage(data: AppManager.shared.getLogoImage())
                let logoRect = CGRect(x: x_logo, y: y_logo, width: 50, height: 50)
                logoImage?.draw(in: logoRect)
                
                // Draw business details
                let businessDetailsAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .paragraphStyle: {
                        let paragraphStyle = NSMutableParagraphStyle()
                        if en {
                            paragraphStyle.alignment = .left
                        } else {
                            paragraphStyle.alignment = .right
                        }
                        return paragraphStyle
                    }(),
                    .foregroundColor: UIColor.gray
                ]
                
                var name = ""
                var id = ""
                var address = ""
                var phone = ""

                if en {
                    name = "Name: "
                    id = "ID: "
                    address = "Address: "
                    phone = "Phone: "
                }
                else {
                    name = "שם: "
                    id = "מזהה: "
                    address = "כתובת: "
                    phone = "טל׳: "
                }

                let businessDetailsText = """
                    \(name) \(VendorManager.shared.vendor.businessName)
                    \(id) \(VendorManager.shared.vendor.businessID)
                    \(address) \(VendorManager.shared.vendor.businessAddress)
                    \(phone) \(VendorManager.shared.vendor.businessPhone)
                """

                businessDetailsText.draw(in: CGRect(x: 50, y: currentY, width: 512, height: 80), withAttributes: businessDetailsAttributes)

                // Update the Y position
                currentY += 80
                
                // Title
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
                
                            if (receiptExists && en){
                                DocumentDateText = "Date created: \(HelperFunctions.formatToDate(receipt_.dateGenerated))"
                            }
                            else if (receiptExists && he){
                                DocumentDateText = "תאריך יצירת המסמך: \(HelperFunctions.formatToDate(receipt_.dateGenerated))"
                            }
                            else if (!receiptExists && en){
                                DocumentDateText = "Date created: \(HelperFunctions.formatToDate(Date()))"
                            }
                            else{
                                DocumentDateText = "תאריך יצירת המסמך: \(HelperFunctions.formatToDate(Date()))"
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
                
                //here
                            let priceColumnRect = CGRect(x: 350, y: currentY, width: 150, height: 20)
                            let priceColumnText = "Price"
                            priceColumnText.draw(in: priceColumnRect, withAttributes: columnHeaderAttributes)
                
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
                
                for orderItem in order.orderItems {
                    let dessertNameRect = CGRect(x: 262, y: currentY, width: 200, height: 20)
                    orderItem.inventoryItem.name.draw(in: dessertNameRect, withAttributes: cellAttributes)
                    
                    let quantityRect = CGRect(x: 462, y: currentY, width: 100, height: 20)
                    String(orderItem.quantity).draw(in: quantityRect, withAttributes: cellAttributes)
                    
                    //here
                    let priceRect = CGRect(x: 350, y: currentY, width: 150, height: 20)
                    let formattedOrderItemCost = String(format: "%.2f", orderItem.price) + HelperFunctions.getCurrencySymbol()
                    formattedOrderItemCost.draw(in: priceRect, withAttributes: cellAttributes)

                    
                    // Update the Y position
                    currentY += 20
                }
                
                if order.delivery.cost != 0 {
                    
                    var deliveryItemTitle = ""
                    if en {
                        deliveryItemTitle = "delivery"
                    }
                    else {
                        deliveryItemTitle = "משלוח"
                    }
                    // Draw a separate row for the delivery cost
                    let deliveryCostNameRect = CGRect(x: 262, y: currentY, width: 200, height: 20)
                    deliveryItemTitle.draw(in: deliveryCostNameRect, withAttributes: cellAttributes)

                    let deliveryCostRect = CGRect(x: 350, y: currentY, width: 100, height: 20)
                    let formattedDeliveryCost = String(format: "%.2f", order.delivery.cost) + HelperFunctions.getCurrencySymbol()
                    formattedDeliveryCost.draw(in: deliveryCostRect, withAttributes: cellAttributes)
                    
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
                    totalPriceText = "Total Cost: \(HelperFunctions.getCurrencySymbol())\(order.totalPrice)"
                }
                else {
                    totalPriceText = "עלות כוללת: ₪\(order.totalPrice)"
                }
                totalPriceText.draw(in: totalPriceRect, withAttributes: totalPriceAttributes)
                
                // Update the Y position
                currentY += 50
                
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
                paymentMethodText.draw(in: paymentDetailsRect, withAttributes: paymentDetailsAttributes)
                
                // Update the Y position for the next detail
                currentY += 20
                
                var paymentDateText = ""
                if en {
                    paymentDateText = "Payment Date: \(HelperFunctions.formatToDate(receipt_.paymentDate))"
                }
                else {
                    paymentDateText = "מועד התשלום: \(HelperFunctions.formatToDate(receipt_.paymentDate))"
                }
                paymentDateText.draw(in: CGRect(x: 50, y: currentY, width: 512, height: 20), withAttributes: paymentDetailsAttributes)
                
                //  signature
                var x_sign = pageRect.width - 150
                let y_sign = pageRect.height - 150
                if en {
                    x_sign = 50
                }
                let signatureImage = UIImage(data: AppManager.shared.getSignatureImage())
                   let signatureRect = CGRect(x: x_sign, y: y_sign, width: 50, height: 50)
                   signatureImage?.draw(in: signatureRect)
            }
            
            return pdfData
        
    }
    
    
    //////
    ///
    ///
    ///
    
    static func drawPreviewPDF(for order: Order) -> Data {
        let receipt_ = order.receipt!
        let receiptExists = true

        // Fetch the preferred localization
        let preferredLanguage = Bundle.main.preferredLocalizations.first ?? "en"
        let isEnglish = preferredLanguage == "en"

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
            
            // Draw watermark
            drawWatermark(in: context, pageRect: pageRect)
            
            var currentY: CGFloat = 50
            let xLogo = isEnglish ? pageRect.width - 100 : 50
            let logoRect = CGRect(x: xLogo, y: 50, width: 50, height: 50)
            
            if let logoImage = UIImage(data: AppManager.shared.getLogoImage()) {
                logoImage.draw(in: logoRect)
            }

            let businessDetails = [
                "Name": VendorManager.shared.vendor.businessName,
                "ID": VendorManager.shared.vendor.businessID,
                "Address": VendorManager.shared.vendor.businessAddress,
                "Phone": VendorManager.shared.vendor.businessPhone
            ]
            let businessDetailsText = formatBusinessDetails(businessDetails, isEnglish: isEnglish)
            drawText(businessDetailsText, at: CGPoint(x: 50, y: currentY), width: 512, height: 80, fontSize: 12)
            
            currentY += 80
            let receiptID = String(receipt_.myID)
            let receiptTitle = String(format: NSLocalizedString("Receipt No. %@", comment: ""), receiptID)
            drawText(receiptTitle, at: CGPoint(x: 50, y: currentY), width: 512, height: 50, fontSize: 24, isBold: true)
            
            currentY += 50
            let documentDateText = formatDocumentDate(receipt: receipt_, receiptExists: receiptExists)
            drawText(documentDateText, at: CGPoint(x: 50, y: currentY), width: 512, height: 20, fontSize: 12)
            
            currentY += 50
            drawSectionHeader(NSLocalizedString("Customer Details", comment: "Section header for customer details"), at: CGPoint(x: 50, y: currentY))

            currentY += 25
            let contactDetails = [
                NSLocalizedString("Name", comment: "Customer name label"): order.customer.name,
                NSLocalizedString("Phone", comment: "Customer phone label"): order.customer.phoneNumber
            ]
            drawContactDetails(contactDetails, at: CGPoint(x: 50, y: currentY))
            
            currentY += 50
            drawSectionHeader(NSLocalizedString("Order Details", comment: "Section header for order details"), at: CGPoint(x: 50, y: currentY))

            currentY += 25
            drawTableHeaders(at: CGPoint(x: 50, y: currentY), isEnglish: isEnglish)
            
            currentY += 20
            drawOrderItems(order.orderItems, at: CGPoint(x: 50, y: currentY), isEnglish: isEnglish)
            
            if order.delivery.cost != 0 {
                currentY += CGFloat(order.orderItems.count * 20)
                drawDeliveryCost(order.delivery.cost, at: CGPoint(x: 50, y: currentY), isEnglish: isEnglish)
            }
            
            currentY += 20
            drawTotalCost(order.totalPrice, at: CGPoint(x: 50, y: currentY), isEnglish: isEnglish)
            
            currentY += 50
            drawSectionHeader(NSLocalizedString("Payment Details", comment: "Section header for payment details"), at: CGPoint(x: 50, y: currentY))

            currentY += 25
            let paymentDetails = [
                "Payment Method": receipt_.paymentMethod,
                "Payment Date": HelperFunctions.formatToDate(receipt_.paymentDate)
            ]
            drawPaymentDetails(paymentDetails, at: CGPoint(x: 50, y: currentY), isEnglish: isEnglish)
            
            // Draw signature
            let xSignature = isEnglish ? 50 : pageRect.width - 150
            let signatureRect = CGRect(x: xSignature, y: pageRect.height - 150, width: 50, height: 50)
            
            if let signatureImage = UIImage(data: AppManager.shared.getSignatureImage()) {
                signatureImage.draw(in: signatureRect)
            }
        }
        
        return pdfData
    }

    // Helper methods (for better readability and maintainability)
    
    static func textAlignment() -> NSTextAlignment {
        let locale = Locale.current
        return Locale.characterDirection(forLanguage: locale.identifier) == .rightToLeft ? .right : .left
    }

    static func formatBusinessDetails(_ details: [String: String], isEnglish: Bool) -> String {
        let namePrefix = NSLocalizedString("Name: ", comment: "Business name prefix")
        let idPrefix = NSLocalizedString("ID: ", comment: "Business ID prefix")
        let addressPrefix = NSLocalizedString("Address: ", comment: "Business address prefix")
        let phonePrefix = NSLocalizedString("Phone: ", comment: "Business phone prefix")
        
        return """
        \(namePrefix) \(details["Name"] ?? "")
        \(idPrefix) \(details["ID"] ?? "")
        \(addressPrefix) \(details["Address"] ?? "")
        \(phonePrefix) \(details["Phone"] ?? "")
        """
    }

    static func formatDocumentDate(receipt: Receipt, receiptExists: Bool) -> String {
        let date = receiptExists ? HelperFunctions.formatToDate(receipt.dateGenerated) : HelperFunctions.formatToDate(Date())
        let datePrefix = NSLocalizedString("Date created: ", comment: "Document date created prefix")
        
        return "\(datePrefix) \(date)"
    }

    static func drawText(_ text: String, at point: CGPoint, width: CGFloat, height: CGFloat, fontSize: CGFloat, isBold: Bool = false) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize),
            .paragraphStyle: {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = textAlignment()
                return paragraphStyle
            }()
        ]

        text.draw(in: CGRect(origin: point, size: CGSize(width: width, height: height)), withAttributes: attributes)
    }


    static func drawSectionHeader(_ header: String, at point: CGPoint) {
        drawText(header, at: point, width: 512, height: 25, fontSize: 14, isBold: true)
    }

    static func drawContactDetails(_ details: [String: String], at point: CGPoint) {
        var y = point.y
        let keysInOrder = [
            NSLocalizedString("Name", comment: "Customer name label"),
            NSLocalizedString("Phone", comment: "Customer phone label")
        ]
        
        for key in keysInOrder {
            if let value = details[key] {
                drawText("\(key): \(value)", at: CGPoint(x: point.x, y: y), width: 512, height: 20, fontSize: 12)
                y += 20
            }
        }
    }
    
    static func drawTableHeaders(at point: CGPoint, isEnglish: Bool) {
        let headers = [
            NSLocalizedString("Item", comment: "Table header for item"): CGRect(x: 262, y: point.y, width: 200, height: 20),
            NSLocalizedString("Quantity", comment: "Table header for quantity"): CGRect(x: 462, y: point.y, width: 100, height: 20),
            NSLocalizedString("Price", comment: "Table header for price"): CGRect(x: 350, y: point.y, width: 150, height: 20)
        ]
        
        for (text, rect) in headers {
            drawText(text, at: CGPoint(x: rect.origin.x, y: rect.origin.y), width: rect.width, height: rect.height, fontSize: 12, isBold: true)
        }
    }

    static func drawOrderItems(_ items: [OrderItem], at point: CGPoint, isEnglish: Bool) {
        var y = point.y
        for item in items {
            drawText(item.inventoryItem.name, at: CGPoint(x: 262, y: y), width: 200, height: 20, fontSize: 12)
            drawText(String(item.quantity), at: CGPoint(x: 462, y: y), width: 100, height: 20, fontSize: 12)
            drawText(String(format: "%.2f", item.price) + HelperFunctions.getCurrencySymbol(), at: CGPoint(x: 350, y: y), width: 150, height: 20, fontSize: 12)
            y += 20
        }
    }

    static func drawDeliveryCost(_ cost: Double, at point: CGPoint, isEnglish: Bool) {
        let deliveryText = isEnglish ? "Delivery" : "משלוח"
        drawText(deliveryText, at: CGPoint(x: 262, y: point.y), width: 200, height: 20, fontSize: 12)
        drawText(String(format: "%.2f", cost) + HelperFunctions.getCurrencySymbol(), at: CGPoint(x: 350, y: point.y), width: 100, height: 20, fontSize: 12)
    }

    static func drawTotalCost(_ totalCost: Double, at point: CGPoint, isEnglish: Bool) {
        let totalCostText = isEnglish ? "Total Cost: \(totalCost)\(HelperFunctions.getCurrencySymbol())" : "עלות כוללת: \(totalCost)\(HelperFunctions.getCurrencySymbol())"
        drawText(totalCostText, at: CGPoint(x: 50, y: point.y), width: 512, height: 25, fontSize: 12, isBold: true)
    }
    
    static func drawPaymentDetails(_ details: [String: String], at point: CGPoint, isEnglish: Bool) {
        var y = point.y
        for (key, value) in details {
            drawText(NSLocalizedString(key, comment: "Payment detail key") + ": " + value, at: CGPoint(x: 50, y: y), width: 512, height: 20, fontSize: 12)
            y += 20
        }
    }

    static func drawWatermark(in context: UIGraphicsPDFRendererContext, pageRect: CGRect) {
        let watermarkText = NSLocalizedString("Draft", comment: "Watermark text for draft")
        let fontSize: CGFloat = 72
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .bold),
            .foregroundColor: UIColor.gray.withAlphaComponent(0.5),
            .paragraphStyle: {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                return paragraphStyle
            }()
        ]
        
        let textSize = watermarkText.size(withAttributes: attributes)
        _ = CGRect(
            x: (pageRect.width - textSize.width) / 2,
            y: (pageRect.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        // Save the current graphics state
        context.cgContext.saveGState()
        
        // Rotate the context by 45 degrees
        context.cgContext.translateBy(x: pageRect.width / 2, y: pageRect.height / 2)
        context.cgContext.rotate(by: -45 * .pi / 180)
        context.cgContext.translateBy(x: -textSize.width / 2, y: -textSize.height / 2)
        
        watermarkText.draw(in: CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height), withAttributes: attributes)
        
        // Restore the graphics state
        context.cgContext.restoreGState()
    }



    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    ///////////////////////

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

