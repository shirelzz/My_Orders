//
//  ContentView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

//import SwiftUI

import SwiftUI

struct ContentView: View {
    
    @StateObject private var orderManager = OrderManager.shared
    
    @State private var showAllOrders = false
    @State private var isAddOrderViewPresented = false // This controls the navigation

    
    init() {
        // Load orders from UserDefaults when ContentView is initialized
        OrderManager.shared.loadOrders()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                Button(action: {
                                    isAddOrderViewPresented = true // Activate navigation
                                }) {
                    Image(systemName: "plus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.blue)
                            .padding()
                            .shadow(radius: 4)
                    }
                    .padding()
                    .sheet(isPresented: $isAddOrderViewPresented) {
                                        AddOrderView(orderManager: orderManager)
                }
                List {
                    ForEach(upcomingOrders, id: \.orderID) { order in
                        NavigationLink(destination: OrderDetailsView(order: order)) {
                            OrderRowView(order: order)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
                

                
                NavigationLink(
                    destination: AllOrdersView(orderManager: orderManager),
                    isActive: $showAllOrders
                ) {
                    EmptyView()
                }
                .hidden() // Hidden NavigationLink to programmatically trigger navigation
                
                Button(action: {
                    showAllOrders.toggle()
                }) {
                    Text("All Orders")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationBarTitle("Upcoming Orders")
        }
        .accentColor(.blue)
        .onAppear {
            // Sort orders by order date in ascending order
            orderManager.orders.sort { $0.orderDate < $1.orderDate }
        }
    }
    
    var upcomingOrders: [DessertOrder] {
        return orderManager.orders.filter { !$0.isCompleted }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




//struct ContentView: View {
//
//    @State private var orders: [DessertOrder] = []
//    @StateObject private var orderManager = OrderManager.shared
//
//    init() {
//        // Load orders from UserDefaults when ContentView is initialized
//        OrderManager.shared.loadOrders()
//        print(OrderManager.shared.getOrders())
//
//    }
//
//
//    var body: some View {
//
//
//        NavigationView {
//
//            VStack {
//
//                List(orders, id: \.orderID) { order in
//                    NavigationLink(destination: OrderDetailsView(order: order)) {
//                        OrderRowView(order: order)
//                    }
//                }
//                .listStyle(InsetGroupedListStyle())
//            }
//
//
//            .navigationTitle("Order Management")
//            .navigationBarItems(
//
//                trailing: HStack {
//
//                    NavigationLink(destination: AddOrderView(orderManager: OrderManager.shared)) {
//                        Text("New Order")
//                    }
//
//                    NavigationLink(destination: UpcomingOrdersView(orderManager: OrderManager.shared)) {
//                        Text("Upcoming Orders")
//                    }
//
//                    NavigationLink(destination: AllOrdersView(orderManager: OrderManager.shared)) {
//
//                        Text("All Orders")
//                    }
//
//                }
//            )
//        }
//    }
//}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
