//
//  InventoryContentView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI
import GoogleMobileAds

struct InventoryContentView: View {
    
    @ObservedObject var inventoryManager: InventoryManager
    @State private var selectedItem: InventoryItem = InventoryItem()
    
    @State private var searchText = ""
    @State private var isAddItemViewPresented = false
    @State private var isEditItemViewPresented = false
    @State private var isDetailViewActive = false
    @State private var showDeleteAlert = false
    @State private var isEditing = false
    @State private var isItemDetailsViewPresented = false
    @State private var currency = HelperFunctions.getCurrencySymbol()
    @State private var showClearAlert = false

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    @State private var sortOption: SortOption = .name
        
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case date_new = "Date Added (newest first)"
        case date_old = "Date Added (oldest first)"
        case quantity_high = "Quantity (highest first)"
        case quantity_low = "Quantity (lowest first)"

    }
    
    var sortedItems: [InventoryItem] {
        switch sortOption {
            case .name:
                return filteredItems.sorted { $0.name < $1.name }
            
            case .date_new:
                return filteredItems.sorted { (item1: InventoryItem, item2: InventoryItem) -> Bool in
                        return item1.AdditionDate > item2.AdditionDate
                }
            
            case .date_old:
                return filteredItems.sorted { (item1: InventoryItem, item2: InventoryItem) -> Bool in
                    return item1.AdditionDate < item2.AdditionDate
                }
            
            case .quantity_high:
                return filteredItems.sorted { $0.itemQuantity > $1.itemQuantity }
            
            case .quantity_low:
            return filteredItems.sorted { $0.itemQuantity < $1.itemQuantity }
 
        }
    }
    
    
    var filteredItems: [InventoryItem] {
        if searchText.isEmpty {
            return Array(inventoryManager.getItems())
        } else {
            return Array(inventoryManager.getItems().filter { $0.name.lowercased().contains(searchText.lowercased()) })
        }
    }
    

    var body: some View {
        
        NavigationStack {
            
            ZStack(alignment: .center){
                
                VStack(alignment: .trailing, spacing: 10) {
                    
                    VStack{
                        
                        Image("boxes")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.top)
                            .opacity(0.2)
                            .frame(height: 20)
                    }
                    
                    HStack(alignment: .center){
                                                
                        Menu {
                        
                            Picker("Sort By", selection: $sortOption) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Text(option.rawValue.localized)
                                }
                            }
                        } 
                        label: {
                            Image(systemName: "arrow.up.arrow.down")
//                                .padding(.horizontal)
//                                .resizable()
//                                .frame(width: 16, height: 16)
                        }
                        
                        SearchBar(searchText: $searchText)
                                                
                    }
                    .padding(8)
                    
                    if inventoryItems.isEmpty {
                        Text("No inventory items yet")
                            .font(.headline)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    else
                    {
                        List(sortedItems) { item in
                            NavigationLink(destination: ItemDetailsView(inventoryManager: inventoryManager, item: item))
                            {
                                VStack(alignment: .leading) {

                                    Text(item.name).bold()
                                    Text("Q: \(item.itemQuantity)")
                                    Text("\(item.itemPrice, specifier: "%.2f")\(currency)")
                                }
                            }
                            .contextMenu {
                                
                                Button("Copy name") {
                                    UIPasteboard.general.string = item.name
                                }
                            }
                            .swipeActions {
                                
                                Button("Delete", role: .destructive) {
                                    selectedItem = item
                                    showDeleteAlert = true
                                }
                                
                                Button("Edit", role: .none) {
                                    selectedItem = item
                                    isEditing = true
                                }
                            }
                        }
                        .listStyle(.plain)
                        .alert(isPresented: $showDeleteAlert) {
                            Alert(
                                title: Text("Confirm Deletion"),
                                message: Text("Are you sure you want to delete this item?"),
                                primaryButton: .destructive(
                                    Text("Delete"),
                                    action: {
                                        // Perform delete action here
                                        inventoryManager.deleteItem(item: selectedItem)
                                    }
                                ),
                                secondaryButton: .cancel(Text("Cancel"))
                            )
                        }
                        .sheet(isPresented: $isEditing, content: {
                            EditItemView(inventoryManager: inventoryManager,
                                         item: $selectedItem,
                                         name: selectedItem.name,
                                         price: selectedItem.itemPrice,
                                         quantity: selectedItem.itemQuantity,
                                         size: selectedItem.size,
                                         notes: selectedItem.itemNotes)
                        })
                    }
                }
            }
            .navigationTitle("Inventory Items")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isAddItemViewPresented = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))

                    }
                    .sheet(isPresented: $isAddItemViewPresented) {
                        AddItemView(inventoryManager: inventoryManager)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showClearAlert = true
                    }) {
                        Text("Clear")
                    }
                    .alert(isPresented: $showClearAlert) {
                        Alert(
                            title: Text("Clear Out of Stock Items"),
                            message: Text("Are you sure you want to delete all items with quantity 0?"),
                            primaryButton: .destructive(Text("Delete")) {
                                // Handle deletion here
                                let ans = inventoryManager.clearOutOfStockItems()
                                if ans == (true, true) {
                                    Toast.showToast(message: "Items cleared successfully")

                                }
                                else if ans == (false, false){
                                    Toast.showAlert(message: "No items to delete")
                                }
                                else if ans == (true, false){
                                    Toast.showAlert(message: "An error accured")
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
            }

            Spacer()
            
            AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                .frame(height: 50)
                .background(Color.white)
            // test: ca-app-pub-3940256099942544/2934735716
            // mine: ca-app-pub-1213016211458907/1549825745
        }
    }
    
    var inventoryItems: [InventoryItem] {
        return inventoryManager.items
    }
    
}


struct InventoryContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        InventoryContentView(inventoryManager: InventoryManager.shared)
    }
}
