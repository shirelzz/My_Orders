//
//  AllReceiptsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 03/10/2023.
//

import SwiftUI
import GoogleMobileAds
//import SSZipArchive
import ZipArchive

struct AllReceiptsView: View {
    
    @ObservedObject var orderManager: OrderManager
//    @ObservedObject var languageManager: LanguageManager

    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                HStack {
                    Picker("Select Year", selection: $selectedYear) {
                        Text("2023").tag(2023)
                        Text("2024").tag(2023)
                        Text("2025").tag(2023)
                        Text("2026").tag(2023)
                    }
                    .pickerStyle(DefaultPickerStyle())
                    .padding()
                    
                    Button("Export Receipts") {
                        exportReceiptsZip()                    }
                }
                
                List {
                    ForEach(filteredReceipts, id: \.id) { receipt in
                        if let order = orderManager.orders.first(where: { $0.orderID == receipt.orderID }) {
                            NavigationLink(destination: GeneratedReceiptView(orderManager: orderManager, order: order, isPresented: .constant(false))) {
                                ReceiptRowView(order: order, receipt: receipt)
                            }
                        } 
//                        else {
//                            Text("Order not found for receipt \(receipt.orderID)")
//                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716") //"ca-app-pub-1213016211458907/1549825745"
                    .frame(height: 50)
//                        .frame(width: UIScreen.main.bounds.width, height: 50)
                    .background(Color.white)
            }
//            .background(Color.accentColor)
//            .opacity(0.2)
            .navigationBarTitle("All Receipts")
        }
    }
    
    var filteredReceipts: [Receipt] {
        return orderManager.receipts.filter { receipt in
            let receiptYear = Calendar.current.component(.year, from: receipt.dateGenerated)
            return receiptYear == selectedYear
        }
    }
    
    private func exportReceiptsZip() {
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

    
    private func exportReceiptsJson() {
        // Filter receipts by the selected year
        let filteredReceipts = orderManager.receipts.filter { receipt in
            let receiptYear = Calendar.current.component(.year, from: receipt.dateGenerated)
            return receiptYear == selectedYear
        }
        
        // Create a file name for the exported file
        let fileName = "Receipts-\(selectedYear).json"
        
        // Get the documents directory URL
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            do {
                // Encode the filtered receipts as JSON data
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(filteredReceipts)
                
                // Write the JSON data to the file
                try jsonData.write(to: fileURL)
                
                // Create a URL to the exported file
                let exportURL = fileURL
                
                // Create a share activity view controller
                let activityViewController = UIActivityViewController(activityItems: [exportURL], applicationActivities: nil)
                
                // Present the share view controller
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let window = windowScene?.windows.first
                
                if let topViewController = window?.rootViewController {
                    topViewController.present(activityViewController, animated: true, completion: nil)
                }
            } catch {
                // Handle any errors that may occur during the export
                print("Error exporting receipts: \(error.localizedDescription)")
            }
        }
    }
    
    
}

//struct AllReceiptsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AllReceiptsView(orderManager: orderManager)
//    }
//}
