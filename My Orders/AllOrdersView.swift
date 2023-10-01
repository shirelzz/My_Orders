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
        
    }
}

struct AllOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        AllOrdersView(orderManager: OrderManager.shared)
    }
}









//import SwiftUI
//
//struct AllOrdersView: View {
//
//    @ObservedObject var orderManager: OrderManager
//
//    var body: some View {
//        List(orderManager.getOrders()) { order in
//            NavigationLink(destination: OrderDetailsView(order: order)) {
//                OrderRowView(order: order)
//            }
//        }
//
//
//        .navigationBarTitle("All Orders")
//
//
//    }
//
//}
//
//struct AllOrdersView_Previews: PreviewProvider {
//    static var previews: some View {
//        AllOrdersView(orderManager: OrderManager.shared)
//    }
//}

