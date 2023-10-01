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
    
    
    @State private var selectedSortingOption: SortingOption = .orderDate // Initialize with a default option

    enum SortingOption: String, CaseIterable, Identifiable {
        case orderDate = "Order Date"
        case customerName = "Customer Name"
        case orderTotal = "Order Total"

        var id: String { self.rawValue }
    }

    var sortedOrders: [DessertOrder] {
        switch selectedSortingOption {
        case .orderDate:
            return orderManager.getOrders().sorted { $0.orderDate > $1.orderDate }
        case .customerName:
            return orderManager.getOrders().sorted { $0.customer.name < $1.customer.name }
        case .orderTotal:
            return orderManager.getOrders().sorted { $0.totalPrice > $1.totalPrice }
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
        
        VStack {
                    Picker("Sort By", selection: $selectedSortingOption) {
                        ForEach(SortingOption.allCases) { option in
                            Text(option.rawValue)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // You can choose a different style if preferred

                    List(sortedOrders) { order in
                        NavigationLink(destination: OrderDetailsView(order: order)) {
                            OrderRowView(order: order)
                        }
                    }
                    .navigationBarTitle("All Orders")
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

