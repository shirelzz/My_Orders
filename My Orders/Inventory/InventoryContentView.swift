//
//  InventoryContentView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI



struct InventoryContentView: View {
    
    @StateObject private var inventoryManager = InventoryManager.shared
    
    @State private var isAddItemViewPresented = false
    @State private var isEditItemViewPresented = false
    @State private var selectedItem: InventoryItem?
    
    @State private var searchText = ""
    @State private var showDeleteAlert = false
    
    init() {
        // Load items from UserDefaults when InventoryContentView is initialized
        InventoryManager.shared.loadItems()
    }
    
    
    var filteredItems: [InventoryItem] {
        if searchText.isEmpty {
            return Array(inventoryManager.items)
        } else {
            return Array(inventoryManager.items.filter { $0.name.lowercased().contains(searchText.lowercased()) })
        }
    }
    
    
    
    var body: some View {
        
        NavigationStack {
            
            ZStack(alignment: .center){
                
                VStack(alignment: .trailing, spacing: 10) {
                    
                    Button(action: {
                        isAddItemViewPresented = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.blue)
                            .padding()
                            .shadow(radius: 2)
                    }
                    //                        .padding(.top, -40)
                    .sheet(isPresented: $isAddItemViewPresented) {
                        AddItemView()
                    }
                    
                    SearchBar(searchText: $searchText)
                    
                    List(filteredItems) { item in
                        
                        VStack(alignment: .leading) {
                            
                            Text("Name: \(item.name)")
                            Text("Price: \(item.itemPrice)")
                            Text("Q: \(item.itemQuantity)")
                            
                            if(item.itemNotes != ""){
                                Text("Notes: \(item.itemNotes)")
                            }
                            
                            Text("Catalog Number: \(item.catalogNumber)")
                                .contextMenu {
                                    Button("Copy catalog number") {
                                        UIPasteboard.general.string = item.catalogNumber
                                    }
                                }
                            
                            
                        }
                        .swipeActions {
                            
                            Button("Delete", role: .destructive) {
                                selectedItem = item
                                showDeleteAlert = true
                            }
                            
                            Button("Edit", role: .none) {
                                selectedItem = item
                            }
                        }
                    }
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(
                            title: Text("Confirm Deletion"),
                            message: Text("Are you sure you want to delete this item?"),
                            primaryButton: .destructive(
                                Text("Delete"),
                                action: {
                                    // Perform delete action here
                                    inventoryManager.removeItem(item: selectedItem!)
                                    selectedItem = nil
                                }
                            ),
                            secondaryButton: .cancel(Text("Cancel"))
                        )
                    }
                    .sheet(item: $selectedItem) { selectedItem in
                        EditItemView(item: selectedItem,
                                     name: selectedItem.name,
                                     price: selectedItem.itemPrice,
                                     quantity: selectedItem.itemQuantity,
                                     notes: selectedItem.itemNotes)
                    }
                }
            }
            .navigationTitle("Inventory Items")
        }
    }
    
    var inventoryItems: Set<InventoryItem> {
        return inventoryManager.items
    }
    
}


struct InventoryContentView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryContentView()
    }
}
