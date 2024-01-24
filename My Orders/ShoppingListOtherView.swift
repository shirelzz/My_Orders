//
//  ShoppingListOtherView.swift
//  My Orders
//
//  Created by שיראל זכריה on 23/01/2024.
//

import SwiftUI
import FirebaseAuth

struct ShoppingListOtherView: View {

    @StateObject private var shoppingList = ShoppingList.shared
    @State private var newItemName = ""
    @State private var newItemQuantity = ""
    @State private var isNameValid = true
    @State private var isInfoOverlayPresented = false
    @State private var inputText = ""
    @State private var selectedItem: ShoppingItem = ShoppingItem()
    @State private var selectedItem2Fav: ShoppingItem = ShoppingItem()
    @State private var selectedItem2Delete: ShoppingItem = ShoppingItem()
    @State private var addFavoritesItemsPressed = false
    @State private var updatefavorites = false
    @State private var flag = false
    @State private var selectedItem2Check: ShoppingItem = ShoppingItem()
    @State private var isUserSignedIn = Auth.auth().currentUser != nil
    
    var body: some View {
        
        let width = UIScreen.main.bounds.width - 32

        NavigationStack{
            
            ZStack(alignment: .topTrailing) {

                VStack (alignment: .leading, spacing: 10) {

                    VStack{
                        
                        Image("aesthticYellow")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.top)
                            .opacity(0.3)
                            .frame(height: 20)
                        
//                        HStack {
//                            
//                            Spacer(minLength: 10)
//                            
//                            Button(action: {
//                                addFavoritesItemsPressed.toggle()
//                                
//                                if addFavoritesItemsPressed && !flag {
//                                    shoppingList.addFavItemsInList()
//                                    flag = true
//                                }
//                                
//                                shoppingList.updateFavItemsInList(add: addFavoritesItemsPressed)
//                                
//                            }, label: {
//                                Image(systemName: addFavoritesItemsPressed ? "heart.circle.fill" : "heart.circle")
//                                    .foregroundColor(addFavoritesItemsPressed ? .accentColor : .black)
//                                    .font(.system(size: 36))
//                            })
//                            .buttonStyle(.borderless)
//                            .padding()
//                            
//                        }
                        
                    }
                }
            }
            .onTapGesture {
                closeKeyboard()
            }
            
            List {
                
                Section(header: Text("Add New Item")) {
                    HStack {
                        TextField("Name", text: $newItemName)
                            .onChange(of: newItemName, perform: { newValue in
                                validateName()
                            })
                        
                        TextField("Quantity", text: $newItemQuantity)
                            .keyboardType(.decimalPad)
                        
                        Button(action: {
                            
                            let newItem = ShoppingItem(
                                
                                shoppingItemID: UUID().uuidString,
                                name: newItemName,
                                quantity: (Double)(newItemQuantity) ?? 0,
                                isChecked: false
                            )
                            
                            shoppingList.addItem(item: newItem)
                            
                            newItemName = ""
                            newItemQuantity = ""
                            
                        }, label: {
                            Text("Add")
                                .buttonBorderShape(.roundedRectangle)
                        })
                        .disabled(!isNameValid || newItemName == "")
                        .buttonStyle(.borderedProminent)
                        .onTapGesture {
                            closeKeyboard()
                        }
                        
                    }
                    
                    if !isNameValid {
                        Text("Item already exists")
                            .foregroundStyle(.red)
                    }
                }
                
                Section(header: Text("Shopping List")) {
                    
                    if currentShoppingItems.isEmpty {
                        
                        Text("No items in your list yet")
                            .font(.headline)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    } else {
                        ForEach(currentShoppingItems, id: \.shoppingItemID) { item in
                            
                            HStack {
                                
                                Button {
                                    selectedItem2Check = item
                                    shoppingList.toggleCheck(item: selectedItem2Check)
                                } label: {
                                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(item.isChecked ? .accentColor : .black)
                                }
                                .buttonStyle(.borderless)
                                
                                Text(item.name)
                                
                                Spacer()
                                
                                TextField("Quantity", text: Binding(
                                    get: {
                                        if item.quantity.rounded() == item.quantity {
                                            return Int(item.quantity).description
                                        } else {
                                            return item.quantity.description
                                        }
                                    },
                                    set: { newValue in
                                        if let newQuantity = Double(newValue) {
                                            shoppingList.updateQuantity(item: item, newQuantity: newQuantity)
                                        }
                                    }
                                ))
                                .keyboardType(.decimalPad)
                                .frame(width: width/6)
                                
                            }
                            .contextMenu(ContextMenu(menuItems: {
                                
                                Button {
                                    selectedItem2Delete = item
                                    shoppingList.deleteItem(item: selectedItem2Delete)
                                } label: {
                                    Text("Delete")
                                        .foregroundStyle(.red)
                                }
                                
                            }))
                            
                        }
                    }
                    
                }
            }
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        closeKeyboard()
                    }
            )
//            .overlay(content: {
//                if isInfoOverlayPresented  { //&& selectedItem != nilItem
//                    CustomDialog(isActive: $isInfoOverlayPresented, item: $selectedItem, title: "Details", buttonTitle: "Save")
//                    //                        .onDisappear {
//                    //                            selectedItem = nilItem
//                    //                            isInfoOverlayPresented = false
//                    //                        }
//                }
//            })
            
            .navigationTitle("Shopping List")

        }
        
        AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
            .frame(height: 50)
            .background(Color.white)
    
    }
    
    private func validateName() {
        var valid = true
        for item in shoppingList.shoppingItems {
            if item.name == newItemName {
                valid = false
            }
        }
        isNameValid = valid
    }
    
    func closeKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var currentShoppingItems: [ShoppingItem] {
        return shoppingList.getSortedItemsByName()
    }
}

#Preview {
    ShoppingListOtherView()
}
