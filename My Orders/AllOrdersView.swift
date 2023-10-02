//
//  AllOrdersView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct AllOrdersView: View {
    
    @ObservedObject var orderManager: OrderManager    
    @State private var searchText = ""

    var filteredOrders: [DessertOrder] {
        if searchText.isEmpty {
            return orderManager.getOrders()
        } else {
            return orderManager.getOrders().filter { order in
                return order.customer.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    
    var body: some View {
        
        VStack {
            SearchBar(searchText: $searchText)
            
            List(filteredOrders, id: \.orderID) { order in
                NavigationLink(destination: OrderDetailsView(order: order)) {
                    OrderRowView(order: order)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarTitle("All Orders")

    }
}

struct AllOrdersView_Previews: PreviewProvider {
    static var previews: some View {
//        _ = DessertOrder(
//            orderID: "123",
//            customer: Customer(name: "John Doe", phoneNumber: 0546768900),
//            desserts: [Dessert(dessertName: "Chocolate Cake", quantity: 2, price: 10.0)],
//            orderDate: Date(),
//            delivery: Delivery(address: "yefe nof 18, peduel", cost: 10) ,
//            notes: "None",
//            allergies: "None",
//            isCompleted: false
//        )
        
        return AllOrdersView(orderManager: OrderManager.shared)
    }
}
