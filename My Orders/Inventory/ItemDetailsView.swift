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
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
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
            }
            .padding()
            .navigationBarTitle("Item Details")
        }
    }
}
    
    struct ItemDetailsView_Previews: PreviewProvider {
        static var previews: some View {
            let sampleItem = InventoryItem(name: "Chocolate cake",
                                           itemPrice: 20,
                                           itemQuantity: 20,
                                           size: "",
                                           AdditionDate: Date(),
                                           itemNotes: ""
            )
            
            ItemDetailsView(inventoryManager: InventoryManager.shared, item: sampleItem)
        }
    }

