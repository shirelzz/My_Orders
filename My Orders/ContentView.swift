//
//  ContentView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI


struct ContentView: View {
    
    @State private var orders: [DessertOrder] = []
    @StateObject private var orderManager = OrderManager.shared
    
    init() {
        // Load orders from UserDefaults when ContentView is initialized
        OrderManager.shared.loadOrders()
        print(OrderManager.shared.getOrders())

    }

    
    var body: some View {
        
        
        NavigationView {
            
            VStack {
                
                List(orders, id: \.orderID) { order in
                    NavigationLink(destination: OrderDetailsView(order: order)) {
                        OrderRowView(order: order)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        
            
            .navigationTitle("Order Management")
            .navigationBarItems(
                
                trailing: HStack {
                    
                    NavigationLink(destination: AddOrderView(orderManager: OrderManager.shared)) {
                        Text("New Order")
                    }
                    
                    NavigationLink(destination: UpcomingOrdersView(orderManager: OrderManager.shared)) {
                        Text("Upcoming Orders")
                    }
                    
                    NavigationLink(destination: AllOrdersView(orderManager: OrderManager.shared)) {
                        
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
