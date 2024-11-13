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
import SwiftUI

class ReceiptUtils {
    
    static let alignment: NSTextAlignment = {
        return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .right : .left
    }()
    
    static func generatePDF(order: Order, receipt: Receipt) -> Data? {
        
        if OrderManager.shared.assignReceiptToOrder(receipt: receipt, toOrderWithID: order.orderID) != nil {
            OrderManager.shared.addReceipt(receipt: receipt)
        }
        
        let pdfData = drawPDF(for: order)
        
        // Specify the file URL where you want to save the PDF
        let fileName = "receipt\(receipt.myID).pdf"
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) else {
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
    
    // The actual drawing of the pdf file
    static func drawReceiptPDF(for order: Order, receipt: Receipt, receiptExists: Bool, isDraft: Bool) -> Data {
        
        let isRightToLeft = alignment == .right
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        
        let pdfMetaData = [
            kCGPDFContextCreator: "My Orders",
            kCGPDFContextAuthor: "Shirel Turgeman"
        ]
        let pdfFormat = UIGraphicsPDFRendererFormat()
        pdfFormat.documentInfo = pdfMetaData as [String: Any]
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: pdfFormat)
        
        let pdfData = renderer.pdfData { context in
            context.beginPage()
            
            // Draw watermark for draft version
            if isDraft {
                drawWatermark(in: context, pageRect: pageRect)
            }
            
            // Logo and text positions based on direction
            let logoXPosition: CGFloat = isRightToLeft ? 50 : pageRect.width - 100
            let textXPosition: CGFloat = isRightToLeft ? pageRect.width - 562 : 50
            
            // Draw Logo
            let logoRect = CGRect(x: logoXPosition, y: 50, width: 50, height: 50)
            if let logoImage = UIImage(data: AppManager.shared.getLogoImage()) {
                logoImage.draw(in: logoRect)
            }
            
            var currentY: CGFloat = 50
            
            // Business Details
            let businessDetails = [
                "Name": VendorManager.shared.vendor.businessName,
                "ID": VendorManager.shared.vendor.businessID,
                "Address": VendorManager.shared.vendor.businessAddress,
                "Phone": VendorManager.shared.vendor.businessPhone
            ]
            let businessDetailsText = formatBusinessDetails(businessDetails)
            drawText(businessDetailsText, at: CGPoint(x: textXPosition, y: currentY), width: 512, fontSize: 12, isBold: false)
            
            currentY += 80
            
            // Receipt Title
            let receiptTitlePart1 = NSLocalizedString("Receipt No.", comment: "")
            let receiptTitle = "\(receiptTitlePart1) \(receipt.myID)"
            drawText(receiptTitle, at: CGPoint(x: textXPosition, y: currentY), width: 512, fontSize: 24, isBold: true)
            
            currentY += 50
            
            // Document Date
            let documentDateText = formatDocumentDate(receipt: receipt, receiptExists: receiptExists)
            drawText(documentDateText, at: CGPoint(x: textXPosition, y: currentY), width: 512, fontSize: 12)
            
            currentY += 50
            
            // Customer Details
            drawSectionHeader("Customer Details", at: CGPoint(x: textXPosition, y: currentY))
            
            currentY += 25
            let contactDetails = [
                NSLocalizedString("Name", comment: "Customer name label"): order.customer.name,
                NSLocalizedString("Phone", comment: "Customer phone label"): order.customer.phoneNumber
            ]
            drawContactDetails(contactDetails, at: CGPoint(x: textXPosition, y: currentY))
            
            currentY += 50
            
            // Order Details Header
            drawSectionHeader("Order Details", at: CGPoint(x: textXPosition, y: currentY))
            
            currentY += 25
            drawTableHeaders(at: CGPoint(x: textXPosition, y: currentY))
            
            currentY += 20
            let orderItemsHeight = drawOrderItems(order.orderItems, at: CGPoint(x: textXPosition, y: currentY))
            
            currentY += orderItemsHeight
            
            // Delivery Cost
            if order.delivery.cost != 0 {
                currentY += 20
                drawDeliveryCost(order.delivery.cost, at: CGPoint(x: textXPosition, y: currentY))
            }
            
            currentY += 20
            
            // Discount Amount and Percentage
            var totalCost = order.totalPrice
            if receipt.discountAmount != 0 {
                totalCost -= receipt.discountAmount ?? 0.0
                drawDiscountAmount(receipt.discountAmount, at: CGPoint(x: textXPosition, y: currentY))
                currentY += 20
            }
            
            if receipt.discountPercentage != 0 {
                let discountValue = (receipt.discountPercentage ?? 0.0) / 100.0 * totalCost
                totalCost -= discountValue
                drawDiscountPercentage(receipt.discountPercentage, at: CGPoint(x: textXPosition, y: currentY))
                currentY += 20
            }
            
            // Total Cost
            drawTotalCost(totalCost, at: CGPoint(x: textXPosition, y: currentY))
            
            currentY += 50
            
            // Payment Details
            drawSectionHeader("Payment Details", at: CGPoint(x: textXPosition, y: currentY))
            
            currentY += 25
            let paymentDetails = [
                "Payment Method": receipt.paymentMethod,
                "Payment Details": receipt.paymentDetails,
                "Payment Date": HelperFunctions.formatToDate(receipt.paymentDate)
            ]
            drawPaymentDetails(paymentDetails, at: CGPoint(x: textXPosition, y: currentY))
            
            // Signature
            let signatureXPosition: CGFloat = isRightToLeft ? pageRect.width - 150 : 50
            let signatureRect = CGRect(x: signatureXPosition, y: pageRect.height - 150, width: 50, height: 50)
            if let signatureImage = UIImage(data: AppManager.shared.getSignatureImage()) {
                signatureImage.draw(in: signatureRect)
            }
        }
        
        return pdfData
    }
    
    static func drawText(_ text: String, at point: CGPoint, width: CGFloat, fontSize: CGFloat, isBold: Bool = false) {
         let paragraphStyle = NSMutableParagraphStyle()
         paragraphStyle.alignment = alignment
         paragraphStyle.lineBreakMode = .byWordWrapping
         
         let attributes: [NSAttributedString.Key: Any] = [
             .font: isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize),
             .paragraphStyle: paragraphStyle
         ]
         
        let textStorage = NSTextStorage(string: NSLocalizedString(text, comment: ""), attributes: attributes)
         let textContainer = NSTextContainer(size: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
         textContainer.lineBreakMode = .byWordWrapping
         
         let layoutManager = NSLayoutManager()
         layoutManager.addTextContainer(textContainer)
         textStorage.addLayoutManager(layoutManager)
         
         layoutManager.drawGlyphs(forGlyphRange: layoutManager.glyphRange(for: textContainer), at: point)
     }

    
    // For an already generated receipt
    static func drawPDF(for order: Order) -> Data {
        
        let receipt_ = OrderManager.shared.getReceipt(forOrderID: order.orderID)
        let receiptExists = OrderManager.shared.receiptExists(forOrderID: order.orderID)
        
        let receiptPdfData = drawReceiptPDF(for: order, receipt: receipt_, receiptExists: receiptExists, isDraft: false)
        return receiptPdfData
    }
    
    // For a not yet generated receipt
    static func drawPreviewPDF(for order: Order) -> Data {
        let receipt_ = order.receipt!
        let receiptExists = true
        
        let receiptPdfData = drawReceiptPDF(for: order, receipt: receipt_, receiptExists: receiptExists, isDraft: true)
        return receiptPdfData
    }
    
    
    // Helper methods
    
    static func formatBusinessDetails(_ details: [String: String]) -> String {
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
    
    static func drawSectionHeader(_ header: String, at point: CGPoint) {
        drawText(header, at: point, width: 512, fontSize: 14, isBold: true)
    }
    
    static func drawContactDetails(_ details: [String: String], at point: CGPoint) {
        var y = point.y
        let keysInOrder = [
            NSLocalizedString("Name", comment: "Customer name label"),
            NSLocalizedString("Phone", comment: "Customer phone label")
        ]
        
        for key in keysInOrder {
            if let value = details[key] {
                drawText("\(key): \(value)", at: CGPoint(x: point.x, y: y), width: 512, fontSize: 12)
                y += 20
            }
        }
    }
    
    static func drawTableHeaders(at point: CGPoint) {
        let isRightToLeft = alignment == .right
        
        // Arrange headers based on text direction
        let headers = isRightToLeft
            ? [
                NSLocalizedString("Item", comment: "Table header for item"): CGRect(x: 350, y: point.y, width: 200, height: 20),
                NSLocalizedString("Quantity", comment: "Table header for quantity"): CGRect(x: 200, y: point.y, width: 100, height: 20),
                NSLocalizedString("Price", comment: "Table header for price"): CGRect(x: 50, y: point.y, width: 150, height: 20)
            ]
            : [
                NSLocalizedString("Item", comment: "Table header for item"): CGRect(x: 50, y: point.y, width: 150, height: 20),
                NSLocalizedString("Quantity", comment: "Table header for quantity"): CGRect(x: 200, y: point.y, width: 100, height: 20),
                NSLocalizedString("Price", comment: "Table header for price"): CGRect(x: 350, y: point.y, width: 200, height: 20)
            ]
        
        for (text, rect) in headers {
            drawText(text, at: CGPoint(x: rect.origin.x, y: rect.origin.y), width: rect.width, fontSize: 12, isBold: true)
        }
    }
    
    static func drawOrderItems(_ items: [OrderItem], at point: CGPoint) -> CGFloat {
        var y = point.y
        let itemWidth: CGFloat = 200
        let quantityWidth: CGFloat = 100
        let priceWidth: CGFloat = 150
        let rowHeight: CGFloat = 40 // Increased to accommodate multi-line text
        
        let isRightToLeft = alignment == .right
        
        // Define X positions based on language direction
        let itemXPosition: CGFloat = isRightToLeft ? 350 : 50
        let quantityXPosition: CGFloat = isRightToLeft ? 200 : 250
        let priceXPosition: CGFloat = isRightToLeft ? 50 : 350
        
        var totalHeight: CGFloat = 0
        
        for item in items {
            let itemName = item.inventoryItem.name
            let itemQuantity = String(item.quantity)
            let itemPrice = String(format: "%.2f", item.price) + HelperFunctions.getCurrencySymbol()
            
            let itemHeight = max(calculateTextHeight(for: itemName, width: itemWidth, fontSize: 12), rowHeight)
            
            // Draw each field in the appropriate position
            drawText(itemName, at: CGPoint(x: itemXPosition, y: y), width: itemWidth, fontSize: 12)
            drawText(itemQuantity, at: CGPoint(x: quantityXPosition, y: y), width: quantityWidth, fontSize: 12)
            drawText(itemPrice, at: CGPoint(x: priceXPosition, y: y), width: priceWidth, fontSize: 12)
            
            y += itemHeight
            totalHeight += itemHeight
        }
        
        return totalHeight
    }
    
    static func calculateTextHeight(for text: String, width: CGFloat, fontSize: CGFloat) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize),
            .paragraphStyle: {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .left
                paragraphStyle.lineBreakMode = .byWordWrapping
                return paragraphStyle
            }()
        ]
        
        let textStorage = NSTextStorage(string: text, attributes: attributes)
        let textContainer = NSTextContainer(size: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        textContainer.lineBreakMode = .byWordWrapping
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let textHeight = layoutManager.usedRect(for: textContainer).height
        return textHeight
    }

    
    // Function to draw the discount amount
    static func drawDiscountAmount(_ discountAmount: Double?, at point: CGPoint) {
        guard let discountAmount = discountAmount else { return }
        
        let discountText = String(format: NSLocalizedString("Discount Amount: %.2f %@", comment: "Label for discount amount"), discountAmount, HelperFunctions.getCurrencySymbol())
        drawText(discountText, at: CGPoint(x: point.x, y: point.y), width: 300, fontSize: 12)
    }
    
    // Function to draw the discount percentage
    static func drawDiscountPercentage(_ discountPercentage: Double?, at point: CGPoint) {
        guard let discountPercentage = discountPercentage else { return }
        
        let discountText = String(format: NSLocalizedString("Discount Percentage: %.2f%%", comment: "Label for discount percentage"), discountPercentage)
        drawText(discountText, at: CGPoint(x: point.x, y: point.y), width: 300, fontSize: 12)
    }
    
    static func drawDeliveryCost(_ cost: Double, at point: CGPoint) {
        let deliveryText = NSLocalizedString("Delivery", comment: "Delivery cost label")
        drawText(deliveryText, at: CGPoint(x: 50, y: point.y), width: 200, fontSize: 12)
        drawText(String(format: "%.2f", cost) + HelperFunctions.getCurrencySymbol(), at: CGPoint(x: 350, y: point.y), width: 100, fontSize: 12)
    }
    
    static func drawTotalCost(_ totalCost: Double, at point: CGPoint) {
        let totalCostFormat = NSLocalizedString("Total Cost: %@ %@", comment: "Label for total cost with value and currency")
        let formattedTotalCost = String(format: "%.2f", totalCost)
        let currencySymbol = HelperFunctions.getCurrencySymbol()
        let totalCostText = String(format: totalCostFormat, formattedTotalCost, currencySymbol)
        drawText(totalCostText, at: CGPoint(x: 50, y: point.y), width: 512, fontSize: 12, isBold: true)
    }
    
    
    static func drawPaymentDetails(_ details: [String: String], at point: CGPoint) {
        var y = point.y
        for (key, value) in details {
            drawText(NSLocalizedString(key, comment: "Payment detail key") + ": " + NSLocalizedString(value, comment: "Payment detail value"), at: CGPoint(x: 50, y: y), width: 512, fontSize: 12)
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
    
    
    static func exportReceiptAsPDF(orderManager: OrderManager, selectedYear: Int, completion: @escaping () -> Void) {
        
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        
        // Create a temporary directory to store individual PDFs
        let tempPDFDirectory = tempDirectory.appendingPathComponent("TempPDFs")
        
        // Ensure the temporary directory exists
        do {
            if !fileManager.fileExists(atPath: tempPDFDirectory.path) {
                try fileManager.createDirectory(at: tempPDFDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print("Error creating temporary PDF directory: \(error.localizedDescription)")
            completion() // Call completion handler in case of an error
            return
        }
        
        // Filter receipts by the selected year
        let filteredReceipts = orderManager.receipts.filter { receipt in
            let receiptYear = Calendar.current.component(.year, from: receipt.dateGenerated)
            return receiptYear == selectedYear
        }
        
        // Create a PDF for each receipt and save it in the temporary directory
        for (index, receipt) in filteredReceipts.enumerated() {
            let order = orderManager.getOrder(orderID: receipt.orderID)
            
            if order.orderID != "" {
                let pdfData = ReceiptUtils.drawPDF(for: order)
                let pdfFileName = "Receipt-\(index + 1).pdf"
                let pdfFileURL = tempPDFDirectory.appendingPathComponent(pdfFileName)
                
                do {
                    try pdfData.write(to: pdfFileURL)
                } catch {
                    print("Error saving PDF: \(error.localizedDescription)")
                }
            }
        }
        
        // Create a zip file name for the exported file
        let zipFileName = "Receipts-\(selectedYear).zip"
        let zipFileURL = tempDirectory.appendingPathComponent(zipFileName)
        
        // Create a zip archive containing all PDFs in the temporary directory
        SSZipArchive.createZipFile(atPath: zipFileURL.path, withContentsOfDirectory: tempPDFDirectory.path)
        
        // Clean up the temporary directory after creating the zip
        do {
            try fileManager.removeItem(at: tempPDFDirectory)
        } catch {
            print("Error cleaning up temporary directory: \(error.localizedDescription)")
        }
        
        // Create a share activity view controller
        let activityViewController = UIActivityViewController(activityItems: [zipFileURL], applicationActivities: nil)
        
        // Present the share view controller
        DispatchQueue.main.async {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            
            if let topViewController = window?.rootViewController {
                topViewController.present(activityViewController, animated: true, completion: nil)
            }
            
            // Call completion handler after presenting the share view controller
            completion()
        }
    }
    
    static private func sanitizeForCSV(_ text: String) -> String {
        // Escape double quotes by doubling them and replace control characters
        let sanitized = text.replacingOccurrences(of: "\"", with: "\"\"") // Escape double quotes
            .components(separatedBy: .controlCharacters).joined() // Remove control characters
            .replacingOccurrences(of: "\n", with: " ") // Replace newline with space
            .replacingOccurrences(of: "\r", with: " ") // Replace carriage return with space
            .trimmingCharacters(in: .whitespacesAndNewlines) // Trim spaces and newlines
        
        return sanitized
    }

    static func exportReceiptsAsCSV(orderManager: OrderManager,
                                    selectedYear: Int,
                                    viewController: UIViewController,
                                    completion: @escaping (Bool, Error?) -> Void) {
        
        // Define the CSV headers and the data string
//        var csvText = "ReceiptID, OrderID, Date, Amount\n"
        var csvText = "Document Date, Document Number, Document Type, Value Date, Payment Method, Payment Details, Payment Amount, Customer Name\n"

        // Filter receipts by the selected year and then sort by paymentDate
        let filteredReceipts = orderManager.receipts
            .filter { receipt in
                let receiptYear = Calendar.current.component(.year, from: receipt.dateGenerated)
                return receiptYear == selectedYear
            }
            .sorted { $0.paymentDate < $1.paymentDate }

        
        // Iterate over each receipt and extract relevant details
        for (_, receipt) in filteredReceipts.enumerated() {
            let order = orderManager.getOrder(orderID: receipt.orderID)
            
            if order.orderID != "" {
                
//                let documentDate = HelperFunctions.formatToDate(receipt.dateGenerated)
//                let documentNumber = receipt.myID
//                let documentType = "receipt"
//                let valueDate = HelperFunctions.formatToDate(receipt.paymentDate)
//                print("receipt.paymentDate: \(receipt.paymentDate)")
//                print("valueDate: \(valueDate)")
//                let paymentMethod = receipt.paymentMethod
//                let paymentDetails = receipt.paymentDetails
//                let paymentAmount = String(format: "%.2f", order.totalPrice)
//                let customerName = String(order.customer.name)
//                print("customerName: \(order.customer.name)")
                
                let documentDate = sanitizeForCSV(HelperFunctions.formatToDate(receipt.dateGenerated))
                let documentNumber = sanitizeForCSV("\(receipt.myID)")
                let documentType = sanitizeForCSV("receipt")
                let valueDate = sanitizeForCSV(HelperFunctions.formatToDate(receipt.paymentDate))
                let paymentMethod = sanitizeForCSV(receipt.paymentMethod)
                let paymentDetails = sanitizeForCSV(receipt.paymentDetails)
                let paymentAmount = sanitizeForCSV(String(format: "%.2f", order.totalPrice))
                let customerName = sanitizeForCSV(order.customer.name)

                let csvLine = "\"\(documentDate)\",\"\(documentNumber)\",\"\(documentType)\",\"\(valueDate)\",\"\(paymentMethod)\",\"\(paymentDetails)\",\"\(paymentAmount)\",\"\(customerName)\"\r\n"


                
                orderManager.printOrder(order: order)
                orderManager.printReceipt(receipt: receipt)
                print(csvLine)
                print("----------------------------------------------")
                
                csvText += csvLine
            }
        }
        
        // Create a temporary file URL for the CSV
        let fileName = "receipts_" + selectedYear.description + ".csv"
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        // Write the CSV data to the temporary file
        do {
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // Use UIActivityViewController to share the CSV file
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = viewController.view
            
            // Present the share sheet
            viewController.present(activityViewController, animated: true) {
                // Call completion with success once the UIActivityViewController is presented
                completion(true, nil)
            }
            
        } catch {
            // Call completion with failure and error if writing to the file fails
            completion(false, error)
        }
    }


}

#Preview(body: {
    AllReceiptsView(orderManager: OrderManager.shared)
})
