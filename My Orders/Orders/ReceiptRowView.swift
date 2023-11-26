//
//  ReceiptRowView.swift
//  My Orders
//
//  Created by שיראל זכריה on 03/10/2023.
//

import SwiftUI

struct ReceiptRowView: View {
    
    let order: DessertOrder
    let receipt: Receipt

    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Customer: \(order.customer.name)") // Access the customer's name
            Text("Date: \(dateFormatter.string(from: order.orderDate))")
            Text("Total Price: ₪\(order.totalPrice,  specifier: "%.2f")")
            
            if order.isCompleted == true{
                
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
}

//struct ReceiptRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReceiptRowView()
//    }
//}
