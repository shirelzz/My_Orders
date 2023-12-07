//
//  AllInventoryItemsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI


struct AllInventoryItemsView: View {
    
    @ObservedObject var inventoryManager: InventoryManager
    @State private var searchText = ""

    var filteredItems: [InventoryItem] {
        if searchText.isEmpty {
            return Array(inventoryManager.items)
        } else {
            return Array(inventoryManager.items.filter { $0.name.lowercased().contains(searchText.lowercased()) })
        }
    }

    var body: some View {
        
//        NavigationView {
            
            VStack {
                
                SearchBar(searchText: $searchText)

                List(filteredItems) { item in
                        VStack(alignment: .leading) {
//                            Text("Catalog Number: \(item.catalogNumber)")
                            Text("Name: \(item.name)")
                            Text("Price: \(item.itemPrice)")
                        }
                }
                .navigationBarTitle("All Inventory Items")
            }
//        }
    }
}

struct AllInventoryItemsView_Previews: PreviewProvider {
    static var previews: some View {
        AllInventoryItemsView(inventoryManager: InventoryManager.shared)
    }
}

//
//#Preview {
//    AllInventoryItemsView()
//}
