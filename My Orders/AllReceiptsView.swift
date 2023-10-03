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
                Picker("Select Year", selection: $selectedYear) {
                    // Provide a list of years you want to filter by (e.g., recent years)
                    Text("2023").tag(2023)
                    Text("2022").tag(2022)
                    // Add more years as needed
                }
                .pickerStyle(DefaultPickerStyle())
                .padding()
                
                List {
                    ForEach(filteredReceipts, id: \.id) { receipt in
                        if let order = orderManager.orders.first(where: { $0.orderID == receipt.orderID }) {
                            NavigationLink(destination: ReceiptView(order: order, isPresented: .constant(false))) {
                                Text("Order \(receipt.orderID)")
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
}


//struct AllReceiptsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AllReceiptsView()
//    }
//}
