//
//  My_OrdersApp.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

@main
struct MyOrdersApp: App {
    
    let orderManager = OrderManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(orderManager)

        }
    }
}
