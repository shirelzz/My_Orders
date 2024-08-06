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
    @State private var isExporting: Bool = false // State variable for loading indicator
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
                let order1 = orderManager.getOrderFromID(forOrderID: receipt1.orderID)
                let order2 = orderManager.getOrderFromID(forOrderID: receipt2.orderID)
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
        let lowercaseSearchText = searchText.lowercased()
        print("---> Search Text: \(searchText), Lowercase Search Text: \(lowercaseSearchText)")
        
        let filtered = orderManager.getReceipts(forYear: selectedYear)
            .filter { receipt in
                print("---> \(receipt.id)")
                let order = orderManager.getOrderFromID(forOrderID: receipt.orderID)
                let lowercaseCustomerName = order.customer.name.lowercased()
                print("---> Customer Name: \(order.customer.name), Lowercase Customer Name: \(lowercaseCustomerName)")
                
                return lowercaseSearchText.isEmpty || lowercaseCustomerName.localizedCaseInsensitiveContains(lowercaseSearchText)
            }
        
        print("---> Filtered Receipts Count: \(filtered.count)")
        return filtered
    }

    
    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .center){
                VStack (alignment: .trailing, spacing: 10) {
                    
                    VStack{
                        
                        HStack {
                            
                            Menu {
                                
                                Picker("Sort By", selection: $sortOption) {
                                    ForEach(SortOption.allCases, id: \.self) { option in
                                        Text(option.rawValue.localized)
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
//                                    .resizable()
//                                    .frame(width: 16, height: 16)
//                                    .padding(.horizontal)
                            }
                            
                            SearchBar(searchText: $searchText)
                            
                        }
                        .padding(8)
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
                    .listStyle(.plain)
                    
                    AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                        .frame(height: 50)
                        .background(Color.white)
                    // test: ca-app-pub-3940256099942544/2934735716
                    // mine: ca-app-pub-1213016211458907/1549825745
                    
                }
                .navigationTitle("All Receipts")
                .toolbar {
                    Group {
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Picker("", selection: $selectedYear) {
                                ForEach(2020...2030, id: \.self) {
                                    Text(String($0)).bold()
                                }
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            
                            Button(action: {
                                if !isExporting {
                                    isExporting = true
                                    ReceiptUtils.exportReceiptAsPDF(orderManager: orderManager, selectedYear: selectedYear) {
                                        isExporting = false // Reset loading state
                                    }
                                }
                            }) {
                                Text("Export")
                            }
                            .foregroundColor(.accentColor)
                            .disabled(isExporting) // Disable button while exporting
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                isAddItemViewPresented = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                //.padding()
                                //  .shadow(radius: 1)
                            }
                            .sheet(isPresented: $isAddItemViewPresented) {
                                AddReceiptView(orderManager: orderManager, isPresented: $isAddItemViewPresented)
                            }
                        }
                    }
                }
            }
            
        }

    }
    
    
    
}

struct AllReceiptsView_Previews: PreviewProvider {
    static var previews: some View {
        AllReceiptsView(orderManager: OrderManager.shared)
    }
}
