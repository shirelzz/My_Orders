//
//  MenuView.swift
//  My Orders
//
//  Created by שיראל זכריה on 02/12/2023.
//

import SwiftUI

struct MenuView: View {
    
    @Binding var isMenuOpen: Bool

    @ObservedObject var appManager: AppManager
//    @ObservedObject var languageManager: LanguageManager
    @ObservedObject var orderManager: OrderManager
    @ObservedObject var inventoryManager: InventoryManager
    

    var body: some View {
        VStack {
            NavigationLink(destination: AllOrdersView(orderManager: orderManager, inventoryManager: inventoryManager)) {
                Label("All orders", systemImage: "rectangle.stack")
            }
            .padding()

            NavigationLink(destination: AllReceiptsView(orderManager: orderManager)) {
                Label("All receipts", systemImage: "tray.full")
            }
            .padding()

            NavigationLink(destination: InventoryContentView(inventoryManager: inventoryManager)) {
                Label("Inventory", systemImage: "cube")
            }
            .padding()

            NavigationLink(destination: SettingsView(appManager: appManager, orderManager: orderManager)) {
                Label("Settings", systemImage: "gear")
            }
            .padding()

            Spacer()

            Button("Close Menu") {
                withAnimation {
                    isMenuOpen.toggle()
                }
            }
            .padding()
        }
        .background(Color.gray.opacity(0.3))
    }
}

//#Preview {
//    MenuView(isMenuOpen: false)
//}
