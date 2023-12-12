//
//  ContentView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var appManager = AppManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var orderManager = OrderManager.shared
    @StateObject private var inventoryManager = InventoryManager.shared

    
    @State private var showAllOrders = false
    @State private var showAllReceipts = false
    @State private var isAddOrderViewPresented = false
    @State private var isSideMenuOpen = false
    @State private var showSideMenu = false
        
    init() {
        AppManager.shared.loadManagerData()
        OrderManager.shared.loadOrders()
        OrderManager.shared.loadReceipts()
        InventoryManager.shared.loadItems()
    }
    
    
    var body: some View {
        
        NavigationStack{
            
            ZStack(alignment: .topTrailing) {
                
//                // Side Menu
//                SideMenuView(isSideMenuOpen: $isSideMenuOpen)
//                    .frame(width: UIScreen.main.bounds.width,
//                           alignment: .leading)
//                    .offset(x: isSideMenuOpen ? 0 : -UIScreen.main.bounds.width)
//                    .animation(Animation.easeInOut.speed(2), value: showSideMenu)
//                    .contentShape(Rectangle()) // Enable tap gesture on entire content area
//                    .onTapGesture {
//                    if isSideMenuOpen {
//                            withAnimation {
//                                isSideMenuOpen = false
//                            }
//                    }
//                }
        
                                
                VStack (alignment: .leading, spacing: 10) {
                    
//                    Button(action: {
//                        withAnimation {
//                            isSideMenuOpen.toggle()
//                        }
//                    }) {
//                        Image(systemName: "line.horizontal.3")
//                            .padding()
//                            .foregroundColor(.black)
//                    }
                    
                    HStack {
                        
                        Spacer()
                        
                        Text("Upcoming Orders")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer(minLength: 10)
                        
                        Button(action: {
                            withAnimation {
                                isAddOrderViewPresented = true
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 36))
                                .padding()
                                .shadow(radius: 1)
                        }
                        .sheet(isPresented: $isAddOrderViewPresented) {
                            AddOrderView(
                                orderManager: orderManager,inventoryManager: inventoryManager, languageManager: languageManager)
                        }
                        
                    }
                    
                    if upcomingOrders.isEmpty {
                        
                        Text("No upcoming orders yet")
                            .font(.headline)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        
                    } else {
                        List {
                            ForEach(upcomingOrders, id: \.orderID) { order in
                                NavigationLink(destination: OrderDetailsView(orderManager: orderManager, languageManager: languageManager, order: order)
                                    .onAppear {
                                        isSideMenuOpen = false
                                    }) {
                                    OrderRowView(order: order)
                                }
                            }
//                            .listRowBackground(Color.orange.opacity(0.2))
                        }
                        .listStyle(.plain)
                    }
                    
                    //                    AdBannerView()
                    //                                       .frame(width: UIScreen.main.bounds.width, height: 50)
                    //                                       .background(Color.gray) // Optional background color
                }                
            }
            
            
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    
                    Menu {
                        
                        HStack {
                            NavigationLink(destination: DashboardView(orderManager: orderManager, inventoryManager: inventoryManager)) {
                                Label("Dashboard", systemImage: "chart.pie")
                            }
                        }
                        
                        HStack {
                            NavigationLink(destination: AllOrdersView(orderManager: orderManager, languageManager: languageManager)) {
                                    if #available(iOS 17.0, *) {
                                        Label("All orders", systemImage: "rectangle.stack")
//                                        .symbolEffect(.variableColor.iterative, value: true)
//                                            .symbolEffect(.variableColor.cumulative, value: true)
                                            .symbolEffect(.bounce, value: 1)


                                    } else {
                                        Label("All orders", systemImage: "rectangle.stack")
                                }
                            }
                        }
                        
                        HStack {
                            NavigationLink(destination: AllReceiptsView(orderManager: orderManager, languageManager: languageManager)) {
                                Label("All receipts", systemImage: "tray.full")
                            }
                        }
                        
                        HStack {
                            NavigationLink( destination:
                                                InventoryContentView(inventoryManager: inventoryManager)) {
                                Label("Inventory", systemImage: "cube")
                            }
                        }
                        
                        HStack {
                            NavigationLink(destination: SettingsView(appManager: appManager, languageManager: languageManager, orderManager: orderManager)) {
                                Label("Settings", systemImage: "gear")
                            }
                        }
                        
                        
                    } label: {
                        Image(systemName: "line.horizontal.3")
                    }
                }
            }
        }
    }
    
    var upcomingOrders: [Order] {
        return orderManager.orders.filter { !$0.isDelivered && $0.orderDate > Date()}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

