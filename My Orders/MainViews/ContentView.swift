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
    @StateObject private var shoppingList = ShoppingList.shared
    
    var body: some View {
        
        //                AppOpenAdView(adUnitID: "ca-app-pub-3940256099942544/5575463023")
        // test:  ca-app-pub-3940256099942544/5575463023
        // mine: ca-app-pub-1213016211458907/7841665686
        
        TabView {
            
            UpcomingOrders(orderManager: orderManager, inventoryManager: inventoryManager)
                .tabItem {
                    Label("Upcoming", systemImage: "tray.and.arrow.down.fill")
                }
            
            AllOrdersView(orderManager: orderManager, inventoryManager: inventoryManager)
                .tabItem {
                    Label("All orders", systemImage: "tray.full.fill")
                }
            
            InventoryContentView(inventoryManager: InventoryManager.shared)
                .tabItem {
                    Label("Inventory", systemImage: "archivebox.fill")
                }
            
            AllReceiptsView(orderManager: orderManager)
                .tabItem {
                    Label("Receipts", systemImage: "pencil.and.ellipsis.rectangle")
                }
            
            SettingsView(appManager: AppManager.shared, orderManager: OrderManager.shared)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
