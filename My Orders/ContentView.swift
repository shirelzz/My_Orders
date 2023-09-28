//
//  ContentView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var orders: [DessertOrder] = []

    var body: some View {
        NavigationView {
            
            List {
                ForEach(orders, id: \.orderID) { order in
                    NavigationLink(destination: OrderDetailsView(order: order)) {
                        OrderRowView(order: order)
                    }
                }
            }
            
            .navigationTitle("Order Management")
            .navigationBarItems(
                trailing: HStack {
                    
                    NavigationLink(destination: AddOrderView()) {
                        Text("New Order")
                    }
                    
                    Button(action: {
                        // Action to view upcoming orders
                    }) {
                        Text("Upcoming Orders")
                    }
                    
                    NavigationLink(destination: AllOrdersView(orderManagement: OrderManager.shared)) {
                        Text("All Orders")
                    }

                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
