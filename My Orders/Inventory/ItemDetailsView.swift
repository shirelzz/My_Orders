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
        
        VStack(alignment: .leading, spacing: 10) {
            
            Section(header: Text("Item Information")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.leading)
            ) {
                HStack{
                    Text("Name:")
                    Text((item.name))
                }
                .padding(.leading)
                
                HStack{
                    Text("Price:")
                    Text((String(item.itemPrice)))
                }
                .padding(.leading)
                
                HStack{
                    Text("Quantity:")
                    Text((String(item.itemQuantity)))
                }
                .padding(.leading)
                
                HStack{
                    Text("Size:")
                    Text((String(item.size)))
                }
                .padding(.leading)
                
                HStack{
                    Text("Notes:")
                    Text((String(item.itemNotes)))
                }
                .padding(.leading)
                
                HStack{
                    Text("Date added:")
                    Text((String(item.AdditionDate.formatted())))
                }
                .padding(.leading)
            }
        }
        .padding()
        .navigationBarTitle("Item Details")
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

