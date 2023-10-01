//
//  OrderRowView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct OrderRowView: View {
    let order: DessertOrder // Assuming DessertOrder is your data model
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long // Choose the desired date style
        formatter.timeStyle = .short // Choose the desired time style
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Customer: \(order.customer.name)") // Access the customer's name
            Text("Date: \(dateFormatter.string(from: order.orderDate))")
            Text("Total Price: ₪\(order.totalPrice,  specifier: "%.2f")")
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
}
