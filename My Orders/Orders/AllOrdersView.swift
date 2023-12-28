//
//  AllOrdersView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI
import GoogleMobileAds

struct AllOrdersView: View {
    
    @ObservedObject var orderManager: OrderManager
    @ObservedObject var inventoryManager: InventoryManager
//    @ObservedObject var languageManager: LanguageManager

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
        NavigationStack{
            
            
            ZStack(alignment: .center) {
                
                
                VStack (alignment: .trailing, spacing: 10) {
                    
                    VStack {
                        
                        Image("aesthetic")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.top)
                            .opacity(0.15)
                            .frame( height: 20)
//                            .padding(.bottom)
                            
//                            .frame(maxHeight: 20)
//                            .clipped()
                    }
    
                        HStack {
                            
                            Menu {
                                Picker("Filter", selection: $filterType) {
                                    ForEach(FilterType.allCases, id: \.self) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                            } label: {
                                Image(systemName: "line.horizontal.3.decrease")
                                    .resizable()
                                    .frame(width: 24, height: 24)

                                //                    Image("line.horizontal.3.decrease.circle")
                                //                                Label("Filter by", systemImage: "line.horizontal.3.decrease.circle")
                                //                                    .font(.system(size: 18))
                            }
                            //                .padding()
                            
                            SearchBar(searchText: $searchText)

                            
                        }
//                        .padding(.top, 45)
                        .padding()
//                        .frame(height: 100)
                    
                    
                    if filteredOrders.isEmpty {
                        
                        Text("No orders yet")
                            .font(.headline)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    }
                    else
                    {
                        
                        List {
                            ForEach(filteredOrders, id: \.orderID) { order in
                                NavigationLink(destination: OrderDetailsView(orderManager: orderManager, inventoryManager: inventoryManager, order: order)) {
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
                    
                    AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716") //"ca-app-pub-1213016211458907/1549825745"
                        .frame(height: 50)
                    //                        .frame(width: UIScreen.main.bounds.width, height: 50)
                        .background(Color.white)
                }
            }
            .navigationBarTitle("All Orders")

        }

    }
    
    private func deleteOrder(orderID: String) {
        orderManager.removeOrder(with: orderID)
    }
    
}

struct AllOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        
        return AllOrdersView(orderManager: OrderManager.shared, inventoryManager: InventoryManager.shared)
    }
}
