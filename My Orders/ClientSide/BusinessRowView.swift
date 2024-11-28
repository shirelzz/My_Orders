//
//  BusinessRowView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/01/2024.
//

import SwiftUI

struct BusinessRowView: View {

    let bus: Business
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(": \(bus.name)")
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
}

//#Preview {
//    let items: [InventoryItem] = [InventoryItem(itemID: "123", name: "popcorn", itemPrice: 30, itemQuantity: 35, size: "", AdditionDate: Date(), itemNotes: ""), InventoryItem(itemID: "456", name: "pizza", itemPrice: 45, itemQuantity: 35, size: "", AdditionDate: Date(), itemNotes: "")]
//    
//    BusinessRowView(bus: Business(id: "", name: "don pastel", items: items))
//}
