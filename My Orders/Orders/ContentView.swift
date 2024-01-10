//
//  ContentView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI
import GoogleMobileAds
import FirebaseAuth

struct ContentView: View {
    @StateObject private var appManager = AppManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var orderManager = OrderManager.shared
    @StateObject private var inventoryManager = InventoryManager.shared
    
    @State private var selectedOrder: Order = Order()
    @State private var showDeleteAlert = false
    @State private var showAllOrders = false
    @State private var showAllReceipts = false
    @State private var isAddOrderViewPresented = false
    @State private var isSideMenuOpen = false
    @State private var showSideMenu = false
    @State private var isEditOrderViewPresented = false
    @State private var isUserSignedIn = Auth.auth().currentUser != nil
    @State private var showEditOrderView = false

        
    init() {}
    
    
    var body: some View {
        
        NavigationStack{
            
            ZStack(alignment: .topTrailing) {
                
                AppOpenAdView(adUnitID: "ca-app-pub-1213016211458907/7841665686")
                // test:  ca-app-pub-3940256099942544/5575463023
                                
                VStack (alignment: .leading, spacing: 10) {
                    
                    VStack{
                        
                        Image("Desk2")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.top)
                            .opacity(0.2)
                            .frame(height: 20)
                        
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
                                    .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 2)

                            }
                            .sheet(isPresented: $isAddOrderViewPresented) {
                                AddOrderView(
                                    orderManager: orderManager,inventoryManager: inventoryManager)
                            }
                            
                        }
                        .padding(.top, 45)

                    }
                    
                    if upcomingOrders.isEmpty {
                        
                        Text("No upcoming orders yet")
                            .font(.headline)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        
                    } else {
                        List {
                            ForEach(upcomingOrders, id: \.orderID) { order in
                                NavigationLink(destination: OrderDetailsView(orderManager: orderManager, inventoryManager: inventoryManager, order: order)
                                    .onAppear {
                                        isSideMenuOpen = false
                                    }) {
                                        OrderRowView(order: order)
                                    }
                                    .swipeActions {
                                        
                                        Button("Delete") {
                                            // Handle delete action
                                            selectedOrder = order
                                            print("delete pressed")
                                            showDeleteAlert = true
                                        }
                                        .tint(.red)
                                        
                                        
                                        Button("Edit") {
                                            // Handle edit action
                                            selectedOrder = order
                                            if selectedOrder.orderID != ""{
                                                isEditOrderViewPresented = true
                                            }
                                        }
                                        .tint(.gray.opacity(0.4))
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .alert(isPresented: $showDeleteAlert) {
                            Alert(
                                title: Text("Delete Order"),
                                message: Text("Are you sure you want to delete this order?"),
                                primaryButton: .default(Text("Delete")) {
                                    if selectedOrder.orderID != ""{
                                        
                                        if !selectedOrder.isDelivered && !selectedOrder.orderItems.isEmpty{

                                            for orderItem in selectedOrder.orderItems {
                                                // Update the quantity of the selected inventory item
                                                if let selectedItem = inventoryManager.items.first(where: { $0.id == orderItem.inventoryItem.itemID }) {
                                                    inventoryManager.updateQuantity(item: selectedItem,
                                                                                    newQuantity: selectedItem.itemQuantity + orderItem.quantity)

                                                }
                                            }
                                            
                                        }
                                        
                                        deleteOrder(orderID: selectedOrder.orderID)
                                    }
                                },
                                secondaryButton: .cancel(Text("Cancel")) {
                                }
                            )
                        }
                        .sheet(isPresented: $isEditOrderViewPresented) {
                            EditOrderView(orderManager: orderManager, inventoryManager: inventoryManager, order: $selectedOrder, editedOrder: selectedOrder )
                        }
                    }
                    
                    Spacer()
                    
                    AdBannerView(adUnitID: "ca-app-pub-1213016211458907/1549825745")
                        .frame(height: 50)
                        .background(Color.white)
                    // test: ca-app-pub-3940256099942544/2934735716
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
                            NavigationLink(destination: AllOrdersView(orderManager: orderManager, inventoryManager: inventoryManager)) {
                                    if #available(iOS 17.0, *) {
                                        Label("All orders", systemImage: "rectangle.stack")
                                            .symbolEffect(.bounce, value: 1)

                                    } else {
                                        Label("All orders", systemImage: "rectangle.stack")
                                }
                            }
                        }
                        
                        HStack {
                            NavigationLink(destination: AllReceiptsView(orderManager: orderManager)) {
                                Label("All receipts", systemImage: "tray.full")
                            }
                        }
                        
                        HStack {
                            NavigationLink( destination: InventoryContentView(inventoryManager: inventoryManager)) {
                                Label("Inventory", systemImage: "cube")
                            }
                        }
                        
                        HStack {
                            NavigationLink(destination: SettingsView(appManager: appManager , orderManager: orderManager)) {
                                Label("Settings", systemImage: "gear")
                            }
                        }
                        
                    } label: {
                        Image(systemName: "line.horizontal.3")
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func deleteOrder(orderID: String) {
        orderManager.removeOrder(with: orderID)
    }
    
    var upcomingOrders: [Order] {
        return orderManager.getUpcomingOrders()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
