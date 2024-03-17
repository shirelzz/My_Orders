//
//  ItemDetailsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 12/12/2023.
//

import SwiftUI

struct ItemDetailsView: View {
    
    @ObservedObject var inventoryManager: InventoryManager
    @State var item: InventoryItem
    @State private var isEditing = false
    
    var body: some View {
        
        Form {
            
            VStack(alignment: .leading, spacing: 10) {
                
                Section(header: Text("Item Information")
                    .font(.headline)
                    .fontWeight(.bold)
                ) {
                    
                    List {
                        Text("Name: \(item.name)")
                        
                        Text("Price: \(item.itemPrice, specifier: "%.2f")")
                        
                        Text("Quantity: \(String(item.itemQuantity))")
                        
                        Text("Size: \(String(item.size))")
                        
                        Text("Notes: \(String(item.itemNotes))")
                        
                        Text("Date added: \(String(item.AdditionDate.formatted()))")
                    }
                }
                
                Section(header: Text("Tags")
                    .font(.headline)
                    .fontWeight(.bold)
                ) {
                    
                    List {
                        if let tags = item.tags {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag.localized)
                            }
                        } else {
                            Text("No tags available")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
            }
            .padding()
            .navigationBarTitle("Item Details")
            .navigationBarItems(
                                
                            trailing:
                                    
                                Button(action: {
                                    isEditing.toggle()
                                }) {
                                    Text(isEditing ? "Done" : "Edit")
                                }
                        )
            .sheet(isPresented: $isEditing) {
                EditItemView(inventoryManager: inventoryManager, item: $item, name: item.name, price: item.itemPrice, quantity: item.itemQuantity, size: item.size, notes: item.itemNotes)
                
            }
            
        }
    }
    
}
