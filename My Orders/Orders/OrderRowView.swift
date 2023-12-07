//
//  OrderRowView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct OrderRowView: View {
    
    let order: Order
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short 
        return formatter
    }()
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Customer: \(order.customer.name)")
            Text("Date: \(dateFormatter.string(from: order.orderDate))")
            Text("Total Price: $\(order.totalPrice,  specifier: "%.2f")")
            
            if order.isDelivered == true{
                
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
}
