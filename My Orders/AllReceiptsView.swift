//
//  AllReceiptsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 03/10/2023.
//

import SwiftUI

struct AllReceiptsView: View {
    @ObservedObject var orderManager: OrderManager
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
                        exportReceipts()
                    }
                }
                
                List {
                    ForEach(filteredReceipts, id: \.id) { receipt in
                        if let order = orderManager.orders.first(where: { $0.orderID == receipt.orderID }) {
                            NavigationLink(destination: ReceiptView(order: order, isPresented: .constant(false))) {
                                ReceiptRowView(order: order, receipt: receipt)
                            }
                        } else {
                            Text("Order not found for receipt \(receipt.orderID)")
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())


            }
            .navigationBarTitle("All Receipts")
        }
    }
    
    var filteredReceipts: [Receipt] {
        return orderManager.receipts.filter { receipt in
            let receiptYear = Calendar.current.component(.year, from: receipt.dateGenerated)
            return receiptYear == selectedYear
        }
    }
    
        private func exportReceipts() {
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
                    if let topViewController = UIApplication.shared.windows.first?.rootViewController {
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
//        AllReceiptsView()
//    }
//}
