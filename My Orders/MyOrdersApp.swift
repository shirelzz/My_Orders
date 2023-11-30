//
//  My_OrdersApp.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

@main
struct MyOrdersApp: App {
    
//    let appManager = AppManager.shared
//    let orderManager = OrderManager.shared
//    let inventoryManager = InventoryManager.shared


    var body: some Scene {
        
        WindowGroup {
            MainView()
//                .environmentObject(appManager)
//                .environmentObject(orderManager)
//                .environmentObject(inventoryManager)

        }
        
    }
}
