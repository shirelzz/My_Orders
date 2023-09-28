//
//  OrderDetailsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct OrderDetailsView: View {
    
    let order: DessertOrder
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack {
            Text("Customer: \(order.customerName)")
            Text("Order Date: \(Self.dateFormatter.string(from: order.orderDate))")

            // Display a list of desserts in the order
            List(order.desserts, id: \.dessertName) { dessert in
                HStack {
                    Text("\(dessert.dessertName)")
                    Spacer()
                    Text("Quantity: \(dessert.quantity)")
                    Text("Price: $\(dessert.price)")
                }
            }
            
            Text("Total Price: $\(order.totalPrice)")
        }
        .navigationBarTitle("Order Details")
    }
}

struct OrderDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleOrder = DessertOrder(
            orderID: "123",
            customerName: "John Doe",
            desserts: [Dessert(dessertName: "Chocolate Cake", quantity: 2, price: 10.99)],
            orderDate: Date(),
            notes: "None",
            allergies: "None",
            isCompleted: false
        )
        
        return OrderDetailsView(order: sampleOrder)
    }
}
