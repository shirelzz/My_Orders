//
//  OrderRowView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct OrderRowView: View {
    
    @State private var currency = AppManager.shared.currencySymbol(for: AppManager.shared.currency)

    let order: Order
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, HH:mm"
        return formatter
    }()
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(order.customer.name).bold()
            Text(dateFormatter.string(from: order.orderDate)).opacity(0.8)
            Text("\(currency)\(order.totalPrice,  specifier: "%.2f")").opacity(0.8)
            
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
