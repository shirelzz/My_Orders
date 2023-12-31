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
        
//        ZStack{
//            
//            VStack{
                
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
//            }
//
//            Spacer()
//            
//            AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716") //"ca-app-pub-1213016211458907/1549825745"
//                .frame(height: 50)
//                .background(Color.white)
//        }
        

    }
    
    
}
    
    struct ItemDetailsView_Previews: PreviewProvider {
        static var previews: some View {
            let sampleItem = InventoryItem(itemID: "1234",
                                           name: "Chocolate cake",
                                           itemPrice: 20,
                                           itemQuantity: 20,
                                           size: "",
                                           AdditionDate: Date(),
                                           itemNotes: ""
            )
            
            ItemDetailsView(inventoryManager: InventoryManager.shared, item: sampleItem)
        }
    }

