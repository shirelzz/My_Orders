//
//  AllReceiptsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 03/10/2023.
//

import SwiftUI
import GoogleMobileAds
import ZipArchive

struct AllReceiptsView: View {
    
    @ObservedObject var orderManager: OrderManager

    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())  // Date = Date()
    @State private var searchText = ""
    @State private var isAddItemViewPresented = false
    @State private var sortOption: SortOption = .date_new
        
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case date_new = "Date Created (newest first)"
        case date_old = "Date Created (oldest first)"
    }
    
    var sortedReceipts: [Receipt] {
        switch sortOption {
        case .name:
            return filteredReceipts.sorted { receipt1, receipt2 in
                let order1 = orderManager.getOrderFromReceipt(forReceiptID: receipt1.id)
                let order2 = orderManager.getOrderFromReceipt(forReceiptID: receipt2.id)
                return order1.customer.name < order2.customer.name
            }
        case .date_new:
            return filteredReceipts.sorted { (rec1: Receipt, rec2: Receipt) -> Bool in
                return rec1.dateGenerated > rec2.dateGenerated
            }
            
        case .date_old:
            return filteredReceipts.sorted { (rec1: Receipt, rec2: Receipt) -> Bool in
                return rec1.dateGenerated < rec2.dateGenerated
            }
        }
    }
    
    var filteredReceipts: [Receipt] {
        orderManager.getReceipts(forYear: selectedYear)
            .filter { receipt in
                let order = orderManager.getOrderFromReceipt(forReceiptID: receipt.id)
                return searchText.isEmpty || order.customer.name.localizedCaseInsensitiveContains(searchText)  //lowercased().contains(searchText.lowercased())
            }
    }
    
    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .center){
                VStack (alignment: .trailing, spacing: 10) {
                    
                    VStack{
                        
                        HStack{
                            
                            Menu {
                                
                                Picker("Sort By", selection: $sortOption) {
                                    ForEach(SortOption.allCases, id: \.self) { option in
                                        Text(option.rawValue.localized)
                                    }
                                }
                                //.padding()
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .padding()
                            }
                            
                            SearchBar(searchText: $searchText)
                            //                                .padding()
                            
                        }
                        .background {
                            Image("receipts")
                                .resizable()
                                .scaledToFill()
                                .edgesIgnoringSafeArea(.top)
                                .opacity(0.2)
                                .frame(height: 200)
                        }
                        
                    }
                    
                    
                    List(sortedReceipts) { receipt in
                        if let order = orderManager.orders.first(where: { $0.orderID == receipt.orderID }) {
                            NavigationLink(destination: GeneratedReceiptView(orderManager: orderManager, order: order, isPresented: .constant(false))) {
                                ReceiptRowView(order: order, receipt: receipt)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    
                    AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                        .frame(height: 50)
                        .background(Color.white)
                    // test: ca-app-pub-3940256099942544/2934735716
                    // mine: ca-app-pub-1213016211458907/1549825745
                    
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Picker("", selection: $selectedYear) {
                            ForEach(2020...2030, id: \.self) {
                                Text(String($0)).bold()
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Export") {
                            exportReceiptsZip()
                        }
                        .foregroundColor(.accentColor)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isAddItemViewPresented = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            //.padding()
                                .shadow(radius: 1)
                        }
                        .sheet(isPresented: $isAddItemViewPresented) {
                            AddReceiptView(orderManager: orderManager, isPresented: $isAddItemViewPresented)
                        }
                    }
                }
            }
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

struct AllReceiptsView_Previews: PreviewProvider {
    static var previews: some View {
        AllReceiptsView(orderManager: OrderManager.shared)
    }
}
