//
//  UpcomingOrders.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct UpcomingOrdersView: View {
    
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
        .navigationBarTitle("Upcoming Orders")
    }

    func filterUpcomingOrders() -> [DessertOrder] {
        // Get the current date
        let currentDate = Date()

        // Use filter to get orders with order dates greater than or equal to today
        return orderManager.getOrders().filter { order in
            return Calendar.current.isDate(order.orderDate, inSameDayAs: currentDate) || order.orderDate > currentDate
        }
    }
}

struct UpcomingOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        AllOrdersView(orderManager: OrderManager.shared)
    }
}




//struct UpcomingOrdersView: View {
//    @ObservedObject var orderManager: OrderManager
//
//    var body: some View {
//        List(filterUpcomingOrders()) { order in
//            NavigationLink(destination: OrderDetailsView(order: order)) {
//                OrderRowView(order: order)
//            }
//        }
//        .navigationBarTitle("Upcoming Orders")
//    }
//
//    func filterUpcomingOrders() -> [DessertOrder] {
//        // Get the current date
//        let currentDate = Date()
//
//        // Use filter to get orders with order dates greater than or equal to today
//        return orderManager.getOrders().filter { order in
//            return Calendar.current.isDate(order.orderDate, inSameDayAs: currentDate) || order.orderDate > currentDate
//        }
//    }
//}
//
//struct UpcomingOrdersView_Previews: PreviewProvider {
//    static var previews: some View {
//        AllOrdersView(orderManager: OrderManager.shared)
//    }
//}


