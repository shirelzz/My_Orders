//
//  UpcomingOrders.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct UpcomingOrdersView: View {
    
    @ObservedObject var orderManager: OrderManager
    @ObservedObject var languageManager: LanguageManager

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
            
            SearchBar(searchText: $searchText)
            
            List(filteredOrders, id: \.orderID) { order in
                NavigationLink(destination: OrderDetailsView(orderManager: orderManager, languageManager: languageManager,  order: order)) {
                    OrderRowView(order: order)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }

}

struct UpcomingOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingOrdersView(orderManager: OrderManager.shared, languageManager: LanguageManager.shared)
    }
}


