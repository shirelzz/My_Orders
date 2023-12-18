//
//  ReceiptRowView.swift
//  My Orders
//
//  Created by שיראל זכריה on 03/10/2023.
//

import SwiftUI

struct ReceiptRowView: View {
    
//    @ObservedObject var languageManager: LanguageManager //n
    
    let order: Order
    let receipt: Receipt

    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("Customer: \(order.customer.name)")
//            Text("Date: \(dateFormatter.string(from: order.orderDate))")
            HStack{
                Text("Total Price: $")
                Text("\(order.totalPrice,  specifier: "%.2f")")

            }
            Text("isPaid: \(order.isPaid.description)")

            
//            if order.isCompleted {
//                
//            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
}

struct ReceiptRowView_Previews: PreviewProvider {
    static var previews: some View {
        
        let sampleItem = InventoryItem(name: "Chocolate cake",
                                       itemPrice: 20,
                                       itemQuantity: 20,
                                       size: "",
                                       AdditionDate: Date(),
                                       itemNotes: ""
                                       )
        
        let sampleItem_ = InventoryItem(name: "Raspberry pie",
                                       itemPrice: 120,
                                       itemQuantity: 3,
                                        size: "",
                                        AdditionDate: Date(),
                                       itemNotes: "")
        
        let sampleOrder = Order(
            orderID: "1234",
            customer: Customer(name: "John Doe", phoneNumber: "0546768900"),
            desserts: [OrderItem(inventoryItem: sampleItem, quantity: 2,price: sampleItem.itemPrice),
                       OrderItem(inventoryItem: sampleItem_, quantity: 1, price: sampleItem_.itemPrice)],
            orderDate: Date(),
            delivery: Delivery(address: "yefe nof 18, peduel", cost: 10),
            notes: "",
            allergies: "",
            isDelivered: false,
            isPaid: false
            
//            receipt: Receipt(id: "1111", myID: 101, orderID: "1234", pdfData: Data(), dateGenerated: Date(), paymentMethod: "bit", paymentDate: Date())
            
        )
        
        ReceiptRowView(order: sampleOrder,
                       receipt:
                       Receipt(id: "000", myID: 000, orderID: "000", pdfData: Data(), dateGenerated: Date(), paymentMethod: "N/A", paymentDate: Date()))
    }
}
