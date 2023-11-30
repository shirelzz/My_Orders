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
    var filteredOrders: [Order] {
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
                        
            if filteredOrders.isEmpty {
                
                Text("No orders yet")
                    .font(.headline)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            else
            {
                
                SearchBar(searchText: $searchText)
                
                //                List(filteredOrders, id: \.orderID) { order in
                //                    NavigationLink(destination: OrderDetailsView(order: order)) {
                //                        OrderRowView(order: order)
                //                    }
                //                }
                
                List {
                    ForEach(filteredOrders, id: \.orderID) { order in
                        NavigationLink(destination: OrderDetailsView(orderManager: orderManager, order: order)) {
                            OrderRowView(order: order)
                        }
                        .contextMenu {
                            Button(action: {
                                deleteOrder(orderID: order.orderID)
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationBarTitle("All Orders")
    }
    
    private func deleteOrder(orderID: String) {
        // Remove the order with the specified orderID
        orderManager.removeOrder(with: orderID)
    }
    
}

struct AllOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        
        return AllOrdersView(orderManager: OrderManager.shared)
    }
}
