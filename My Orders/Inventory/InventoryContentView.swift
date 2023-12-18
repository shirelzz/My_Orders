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
    
    @State private var isAddItemViewPresented = false
    @State private var isEditItemViewPresented = false
    @State private var isDetailViewActive = false
    
    @State private var selectedItem: InventoryItem?
    
    @State private var searchText = ""
    @State private var showDeleteAlert = false
    @State private var isItemDetailsViewPresented = false

    
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
                    
                    HStack {
                        
                        Spacer()
                        
                        Text("Inventory Items")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                                                
                        Button(action: {
                            isAddItemViewPresented = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 36))
                                .padding()
                                .shadow(radius: 1)
                        }
                        .sheet(isPresented: $isAddItemViewPresented) {
                            AddItemView(inventoryManager: inventoryManager)
                        }
                    }
                    
                    HStack{
                        SearchBar(searchText: $searchText)
                        
                        Menu {
                        
                            Picker("Sort By", selection: $sortOption) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Text(option.rawValue.localized)
                                }
                            }
                        } 
                        label: {
//                          Label("Sort By", systemImage: "") // "line.horizontal.3.decrease.circle"
//                              .font(.system(size: 18))
                            Text("Sort By")
                        }
                    .padding(.horizontal)
                    }
                    
                    
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

                                    Text("Name: \(item.name)")
                                    Text("Price: \(item.itemPrice, specifier: "%.2f")")
                                    Text("Q: \(item.itemQuantity)")
//                                    Text("Date added: \(item.AdditionDate.formatted())")
                                        
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
                                        inventoryManager.deleteItem(item: selectedItem!)
                                        //                                        selectedItem = nil
                                    }
                                ),
                                secondaryButton: .cancel(Text("Cancel"))
                            )
                        }
                        .sheet(item: $selectedItem) { selectedItem in
                            EditItemView(inventoryManager: inventoryManager,
                                         item: selectedItem,
                                         name: selectedItem.name,
                                         price: selectedItem.itemPrice,
                                         quantity: selectedItem.itemQuantity,
                                         size: selectedItem.size,
                                         notes: selectedItem.itemNotes)
                        }
                    }
                }
            }
            
            Spacer()
            
            AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716") //"ca-app-pub-1213016211458907/1549825745"
                .frame(height: 50)
//                        .frame(width: UIScreen.main.bounds.width, height: 50)
                .background(Color.white)
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
