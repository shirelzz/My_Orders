//
//  OrderRowView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct OrderRowView: View {
    let order: DessertOrder // Assuming DessertOrder is your data model
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Customer: \(order.customerName)")
            Text("Order Date: \(formattedDate(order.orderDate))")
            Text("Total Price: $\(order.totalPrice)")
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
}
