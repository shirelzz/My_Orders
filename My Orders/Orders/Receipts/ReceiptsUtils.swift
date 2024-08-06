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
            
            if isDraft {
                // Draw watermark
                drawWatermark(in: context, pageRect: pageRect)
            }
            
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
            let businessDetailsText = formatBusinessDetails(businessDetails)
            drawText(businessDetailsText, at: CGPoint(x: 50, y: currentY), width: 512, height: 80, fontSize: 12)
            
            currentY += 80
            let receiptID = String(receipt.myID)
            let receiptTitle = String(format: NSLocalizedString("Receipt No. %@", comment: ""), receiptID)
            drawText(receiptTitle, at: CGPoint(x: 50, y: currentY), width: 512, height: 50, fontSize: 24, isBold: true)
            
            currentY += 50
            let documentDateText = formatDocumentDate(receipt: receipt, receiptExists: receiptExists)
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
            drawTableHeaders(at: CGPoint(x: 50, y: currentY))
            
            currentY += 20
            drawOrderItems(order.orderItems, at: CGPoint(x: 50, y: currentY))
            
            if order.delivery.cost != 0 {
                currentY += CGFloat(order.orderItems.count * 20)
                drawDeliveryCost(order.delivery.cost, at: CGPoint(x: 50, y: currentY))
            }
            
            currentY += 20
            drawTotalCost(order.totalPrice, at: CGPoint(x: 50, y: currentY))
            
            currentY += 50
            drawSectionHeader(NSLocalizedString("Payment Details", comment: "Section header for payment details"), at: CGPoint(x: 50, y: currentY))

            currentY += 25
            let paymentDetails = [
                "Payment Method": receipt.paymentMethod,
                "Payment Date": HelperFunctions.formatToDate(receipt.paymentDate)
            ]
            drawPaymentDetails(paymentDetails, at: CGPoint(x: 50, y: currentY))
            
            // Draw signature
            let xSignature = isEnglish ? 50 : pageRect.width - 150
            let signatureRect = CGRect(x: xSignature, y: pageRect.height - 150, width: 50, height: 50)
            
            if let signatureImage = UIImage(data: AppManager.shared.getSignatureImage()) {
                signatureImage.draw(in: signatureRect)
            }
        }
        
        return pdfData
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

    // Helper methods (for better readability and maintainability)
    
    static func textAlignment() -> NSTextAlignment {
        let locale = Locale.current
        return Locale.characterDirection(forLanguage: locale.identifier) == .rightToLeft ? .right : .left
    }

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
    
    static func drawTableHeaders(at point: CGPoint) {
        let headers = [
            NSLocalizedString("Item", comment: "Table header for item"): CGRect(x: 262, y: point.y, width: 200, height: 20),
            NSLocalizedString("Quantity", comment: "Table header for quantity"): CGRect(x: 462, y: point.y, width: 100, height: 20),
            NSLocalizedString("Price", comment: "Table header for price"): CGRect(x: 350, y: point.y, width: 150, height: 20)
        ]
        
        for (text, rect) in headers {
            drawText(text, at: CGPoint(x: rect.origin.x, y: rect.origin.y), width: rect.width, height: rect.height, fontSize: 12, isBold: true)
        }
    }

    static func drawOrderItems(_ items: [OrderItem], at point: CGPoint) {
        var y = point.y
        for item in items {
            drawText(item.inventoryItem.name, at: CGPoint(x: 262, y: y), width: 200, height: 20, fontSize: 12)
            drawText(String(item.quantity), at: CGPoint(x: 462, y: y), width: 100, height: 20, fontSize: 12)
            drawText(String(format: "%.2f", item.price) + HelperFunctions.getCurrencySymbol(), at: CGPoint(x: 350, y: y), width: 150, height: 20, fontSize: 12)
            y += 20
        }
    }

    static func drawDeliveryCost(_ cost: Double, at point: CGPoint) {
        let deliveryText = NSLocalizedString("Delivery", comment: "Delivery cost label")
        drawText(deliveryText, at: CGPoint(x: 262, y: point.y), width: 200, height: 20, fontSize: 12)
        drawText(String(format: "%.2f", cost) + HelperFunctions.getCurrencySymbol(), at: CGPoint(x: 350, y: point.y), width: 100, height: 20, fontSize: 12)
    }

    static func drawTotalCost(_ totalCost: Double, at point: CGPoint) {
        let totalCostFormat = NSLocalizedString("Total Cost", comment: "Label for total cost")
        let totalCostText = String(format: totalCostFormat, String(format: "%.2f", totalCost), HelperFunctions.getCurrencySymbol())
        drawText(totalCostText, at: CGPoint(x: 50, y: point.y), width: 512, height: 25, fontSize: 12, isBold: true)
    }
    
    static func drawPaymentDetails(_ details: [String: String], at point: CGPoint) {
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
    
    
    static func exportReceiptAsPDF(orderManager: OrderManager, selectedYear: Int) {
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
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        if let topViewController = window?.rootViewController {
            topViewController.present(activityViewController, animated: true, completion: nil)
        }
    }

}

