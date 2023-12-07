//
//  AllOrdersView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct AllOrdersView: View {
    
    @ObservedObject var orderManager: OrderManager
    @ObservedObject var languageManager: LanguageManager
    @State private var showPaidOrders = true

    @State private var searchText = ""
    @State private var filterType: FilterType = .all
    
    enum FilterType: String, CaseIterable, Identifiable {
        case all = "All"
        case paid = "Paid"
        case delivered = "Delivered"
        
        var id: FilterType { self }
    }
    
    var filteredOrders: [Order] {
        orderManager.getOrders().filter { order in
            let nameMatches = searchText.isEmpty || order.customer.name.localizedCaseInsensitiveContains(searchText)
            
            switch filterType {
            case .paid:
                return nameMatches && order.isPaid
            case .delivered:
                return nameMatches && order.isDelivered
            case .all:
                return nameMatches
            }
        }
    }
    
    
    var body: some View {
        
        VStack {
            
            HStack {
                SearchBar(searchText: $searchText)
                
                Menu {
                                Picker("Filter", selection: $filterType) {
                                    ForEach(FilterType.allCases, id: \.self) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                            } label: {
                                Label("", systemImage: "line.horizontal.3.decrease.circle")
                            }
                    .padding(.trailing)
            }
                        
            if filteredOrders.isEmpty {
                
                Text("No orders yet")
                    .font(.headline)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            else
            {

                List {
                    ForEach(filteredOrders, id: \.orderID) { order in
                        NavigationLink(destination: OrderDetailsView(orderManager: orderManager, languageManager: languageManager, order: order)) {
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
        orderManager.removeOrder(with: orderID)
    }
    
}

struct AllOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        
        return AllOrdersView(orderManager: OrderManager.shared, languageManager: LanguageManager.shared)
    }
}
