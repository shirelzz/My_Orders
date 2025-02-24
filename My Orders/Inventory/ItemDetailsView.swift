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
    @State private var isWiggling = false

    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            BottomRoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .light ? Color.black : Color.white)
                .frame(height: UIScreen.main.bounds.height / 2.5)
                .edgesIgnoringSafeArea(.top)
            
            ScrollView {
                
                VStack(spacing: 12) {
                    
                    
                    // Spacer to create initial offset, making content start lower
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height / 35)
                    
                    itemInformationSection
                    
                    if !item.size.isEmpty || !item.itemNotes.isEmpty {
                        additionalDetailsSection
                    }
                    
                    tagsSection
                    
                }
            }
        }
        .navigationBarTitle("Item Details")
        .navigationBarItems(
            
            trailing:
                
                Button(action: {
                    isEditing.toggle()
                }) {
                    Image(systemName: isEditing ? "pencil.slash" : "pencil")
                        .font(.system(size: 18))
                        .foregroundColor(isEditing ? .red : (colorScheme == .light ? .white : .black))
                }
            
        )
        .sheet(isPresented: $isEditing) {
            EditItemView(inventoryManager: inventoryManager, item: $item, name: item.name, price: item.itemPrice, quantity: item.itemQuantity, size: item.size, notes: item.itemNotes)
            
        }
        
    }
    
    private var itemInformationSection: some View {
        CustomSection(header: "Item Information", headerColor: .gray) {
            
            HStack{
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    CustomSectionView(
                        title: "Name",
                        description: item.name,
                        sfSymbol: "paperclip",
                        sfSymbolColor: Color.accentColor
                    )
                    
                    Divider()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                    
                    CustomSectionView(
                        title: "Quantity",
                        description: String(item.itemQuantity),
                        sfSymbol: "number",
                        sfSymbolColor: Color.accentColor
                    )
                    
                    Divider()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                    
                    CustomSectionView(
                        title: "Price",
                        description: String(item.itemPrice),
                        sfSymbol: "banknote",
                        sfSymbolColor: Color.accentColor
                    )
                    
                    Divider()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                    
                    CustomSectionView(
                        title: "Addition Date",
                        description: String(HelperFunctions.formatToDate(item.AdditionDate)),
                        sfSymbol: "calendar",
                        sfSymbolColor: Color.accentColor
                    )
                
                }
                
                Spacer()
            }
            
        }
        .cornerRadius(12)
    }
    
    private var additionalDetailsSection: some View {
        CustomSection(header: "Additional Details", headerColor: .gray) {
            VStack {
                
                if !item.size.isEmpty {
                    CustomSectionView(
                        title: "Size",
                        description: item.size,
                        sfSymbol: "shippingbox",
                        sfSymbolColor: Color.accentColor
                    )
                    
                    if !item.itemNotes.isEmpty {
                        
                        Divider()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)

                    }

                }
                
                if !item.itemNotes.isEmpty {
                    CustomSectionView(
                        title: "Notes",
                        description: item.itemNotes,
                        sfSymbol: "note.text",
                        sfSymbolColor: Color.accentColor
                    )
                    
                }
 
            }
        }
    }
    
    private var tagsSection: some View {
        CustomSection(header: "Tags", headerColor: .gray) {
            
            HStack{
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    if let tags = item.tags {
                        ForEach(tags, id: \.self) { tag in
                            
                            HStack{
                                
                                Image(systemName: "tag")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 16))
//                                    .rotationEffect(.degrees(isWiggling ? -10 : 10))
//                                    .animation(
//                                        Animation.easeInOut(duration: 0.15)
//                                            .repeatForever(autoreverses: true),
//                                        value: isWiggling
//                                    )
//                                    .onAppear {
//                                        isWiggling = true
//                                    }
                                
                                Text(tag.localized)
                            }
                        }
                    } else {
                        Text("No tags available")
                            .foregroundColor(.gray)
                    }
                    
                }
                
                Spacer()
            }
            
        }
        .cornerRadius(12)
    }

}

    
//struct ItemDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        
//        let sampleItem = InventoryItem(itemID: "1234",
//                                       name: "Chocolate cake",
//                                       itemPrice: 20,
//                                       itemQuantity: 20,
//                                       size: "",
//                                       AdditionDate: Date(),
//                                       itemNotes: "",
//                                       tags: ["Dairy", "Keto"]
//        )
//        
//        return ItemDetailsView(inventoryManager: InventoryManager.shared, item: sampleItem)
//        
////        return InventoryContentView(inventoryManager: InventoryManager.shared, tagManager: TagManager.shared)
//
//    }
//    
//}

#Preview {
    InventoryContentView(inventoryManager: InventoryManager.shared, tagManager: TagManager.shared)
}
