//
//  UpcomingOrders.swift
//  My Orders
//
//  Created by שיראל זכריה on 17/03/2024.
//

import SwiftUI
import GoogleMobileAds
import FirebaseAuth

struct UpcomingOrders: View {
    
    @ObservedObject var orderManager: OrderManager
    @ObservedObject var inventoryManager: InventoryManager
    
    @State var showMenu: Bool = false

    @State private var selectedOrder: Order = Order()
    @State private var showDeleteAlert = false
    @State private var showAllOrders = false
    @State private var showAllReceipts = false
    @State private var isAddOrderViewPresented = false
    @State private var isSideMenuOpen = false
    @State private var showSideMenu = false
    @State private var isEditOrderViewPresented = false
    @State private var isUserSignedIn = Auth.auth().currentUser != nil
    @State private var showEditOrderView = false
    
    var upcomingOrders: [Order] {
        return orderManager.getUpcomingOrders()
    }
    
    var body: some View {
        
        AnimatedSideMenu(rotatesWhenExpands: true,
                         disabledInteraction: true,
                         sideMenuWidth: 200,
                         cornerRadius: 25,
                         showMenu: $showMenu,
                         content: { UIEdgeInsets in
            
                    NavigationStack {
                        ZStack(alignment: .topTrailing) {
                            VStack (alignment: .leading, spacing: 10) {
                                
                                VStack{
                                    
                                    Image("Desk2")
                                        .resizable()
                                        .scaledToFill()
                                        .edgesIgnoringSafeArea(.top)
                                        .opacity(0.2)
                                        .frame(height: 20)
                                    
                                    HStack {
                                        
                                        Text("Upcoming Orders")
                                            .font(.largeTitle)
                                            .bold()
                                            .padding()
                                        
                                        Spacer(minLength: 10)
                                        
                                        Button(action: {
                                            withAnimation {
                                                isAddOrderViewPresented = true
                                            }
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 36))
                                                .padding()
                                                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 2)
                                            
                                        }
                                        .sheet(isPresented: $isAddOrderViewPresented) {
                                            AddOrderView(
                                                orderManager: orderManager,inventoryManager: inventoryManager)
                                        }
                                        
                                    }
                                    .padding()
                                    
                                }
                                
                                if upcomingOrders.isEmpty {
                                    
                                    Text("No upcoming orders yet")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    
                                    
                                } else {
                                    List {
                                        ForEach(upcomingOrders, id: \.orderID) { order in
                                            NavigationLink(destination: OrderDetailsView(orderManager: orderManager, inventoryManager: inventoryManager, order: order)
                                                .onAppear {
                                                    isSideMenuOpen = false
                                                }) {
                                                    OrderRowView(order: order)
                                                }
                                                .swipeActions {
                                                    
                                                    Button("Delete") {
                                                        selectedOrder = order
                                                        showDeleteAlert = true
                                                    }
                                                    .tint(.red)
                                                    
                                                    
                                                    Button("Edit") {
                                                        selectedOrder = order
                                                        if selectedOrder.orderID != ""{
                                                            isEditOrderViewPresented = true
                                                        }
                                                    }
                                                    .tint(.gray) //.opacity(0.4)
                                                }
                                        }
                                    }
                                    .listStyle(.plain)
                                    .refreshable {
                                        await refreshUpcomingOrders()
                                        
                                    }
                                    .alert(isPresented: $showDeleteAlert) {
                                        Alert(
                                            title: Text("Delete Order"),
                                            message: Text("Are you sure you want to delete this order?"),
                                            primaryButton: .default(Text("Delete")) {
                                                if selectedOrder.orderID != ""{
                                                    
                                                    if !selectedOrder.isDelivered && !selectedOrder.orderItems.isEmpty{
                                                        
                                                        for orderItem in selectedOrder.orderItems {
                                                            // Update the quantity of the selected inventory item
                                                            if let selectedItem = inventoryManager.items.first(where: { $0.id == orderItem.inventoryItem.itemID }) {
                                                                inventoryManager.updateQuantity(item: selectedItem,
                                                                                                newQuantity: selectedItem.itemQuantity + orderItem.quantity)
                                                                
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                    deleteOrder(orderID: selectedOrder.orderID)
                                                }
                                            },
                                            secondaryButton: .cancel(Text("Cancel")) {
                                            }
                                        )
                                    }
                                    .sheet(isPresented: $isEditOrderViewPresented) {
                                        
                                        if selectedOrder.orderID != "" {
                                            EditOrderView(orderManager: orderManager, inventoryManager: inventoryManager, order: $selectedOrder, editedOrder: selectedOrder )
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
                        .toolbar{
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    showMenu.toggle()
                                } label: {
                                    Image(systemName: showMenu ? "xmark" : "line.3.horizontal")
                                        .foregroundStyle(.primary)
                                        .contentTransition(.identity)
                                }

                            }
                        }
                        
                    }
                    
            
        }, menuView: { UIEdgeInsets in
            SideBarMenuView(UIEdgeInsets)
        }, background: {
            Rectangle()
                .fill(Color.white)
        }
                            
        )
        
//        NavigationStack {
//            ZStack(alignment: .topTrailing) {
//                VStack (alignment: .leading, spacing: 10) {
//                    
//                    VStack{
//                        
//                        Image(VendorManager.shared.vendor.vendorType == .food ? "kitchen" : "Desk2")
//                            .resizable()
//                            .scaledToFill()
//                            .edgesIgnoringSafeArea(.top)
//                            .opacity(0.2)
//                            .frame(height: 20)
//                        
//                        HStack {
//                                                        
//                            Text("Upcoming Orders")
//                                .font(.largeTitle)
//                                .bold()
//                                .padding()
//                            
//                            Spacer(minLength: 10)
//                            
//                            Button(action: {
//                                withAnimation {
//                                    isAddOrderViewPresented = true
//                                }
//                            }) {
//                                Image(systemName: "plus.circle.fill")
//                                    .font(.system(size: 36))
//                                    .padding()
//                                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 2)
//                                
//                            }
//                            .sheet(isPresented: $isAddOrderViewPresented) {
//                                AddOrderView(
//                                    orderManager: orderManager,inventoryManager: inventoryManager)
//                            }
//                            
//                        }
//                        .padding()
//                        
//                    }
//                    
//                    if upcomingOrders.isEmpty {
//                        
//                        Text("No upcoming orders yet")
//                            .font(.headline)
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        
//                        
//                    } else {
//                        List {
//                            ForEach(upcomingOrders, id: \.orderID) { order in
//                                NavigationLink(destination: OrderDetailsView(orderManager: orderManager, inventoryManager: inventoryManager, order: order)
//                                    .onAppear {
//                                        isSideMenuOpen = false
//                                    }) {
//                                        OrderRowView(order: order)
//                                    }
//                                    .swipeActions {
//                                        
//                                        Button("Delete") {
//                                            selectedOrder = order
//                                            showDeleteAlert = true
//                                        }
//                                        .tint(.red)
//                                        
//                                        
//                                        Button("Edit") {
//                                            selectedOrder = order
//                                            if selectedOrder.orderID != ""{
//                                                isEditOrderViewPresented = true
//                                            }
//                                        }
//                                        .tint(.gray) //.opacity(0.4)
//                                    }
//                            }
//                        }
//                        .listStyle(.plain)
//                        .refreshable {
//                            await refreshUpcomingOrders()
//
//                        }
//                        .alert(isPresented: $showDeleteAlert) {
//                            Alert(
//                                title: Text("Delete Order"),
//                                message: Text("Are you sure you want to delete this order?"),
//                                primaryButton: .default(Text("Delete")) {
//                                    if selectedOrder.orderID != ""{
//                                        
//                                        if !selectedOrder.isDelivered && !selectedOrder.orderItems.isEmpty{
//                                            
//                                            for orderItem in selectedOrder.orderItems {
//                                                // Update the quantity of the selected inventory item
//                                                if let selectedItem = inventoryManager.items.first(where: { $0.id == orderItem.inventoryItem.itemID }) {
//                                                    inventoryManager.updateQuantity(item: selectedItem,
//                                                                                    newQuantity: selectedItem.itemQuantity + orderItem.quantity)
//                                                    
//                                                }
//                                            }
//                                            
//                                        }
//                                        
//                                        deleteOrder(orderID: selectedOrder.orderID)
//                                    }
//                                },
//                                secondaryButton: .cancel(Text("Cancel")) {
//                                }
//                            )
//                        }
//                        .sheet(isPresented: $isEditOrderViewPresented) {
//                            
//                            if selectedOrder.orderID != "" {
//                                EditOrderView(orderManager: orderManager, inventoryManager: inventoryManager, order: $selectedOrder, editedOrder: selectedOrder )
//                            }
//                        }
//                    }
//                    
//                    Spacer()
//                    
//                    AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
//                        .frame(height: 50)
//                        .background(Color.white)
//                    // test: ca-app-pub-3940256099942544/2934735716
//                    // mine: ca-app-pub-1213016211458907/1549825745
//                }
//                .toolbar {
//                    
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        
//                        Menu {
//                            
//                            HStack {
//                                NavigationLink(destination: DashboardView(orderManager: orderManager, inventoryManager: inventoryManager)) {
//                                    Label("Dashboard", systemImage: "chart.pie")
//                                }
//                            }
//                            
//                            HStack {
//                                NavigationLink( destination: ShoppingListView()) {
//                                    Label("Shopping List", systemImage: "cart")
//                                }
//                            }
//                            
//                        } label: {
//                            Image(systemName: "line.horizontal.3")
//                        }
//                    }
//                }
//            }
//        }

    }
    
    @ViewBuilder
    func SideBarMenuView(_ safeArea: UIEdgeInsets) -> some View {
        VStack(alignment: .center, spacing: 10) {
            
            Text("Menu")
            
            SideBarButton(.dashBoard, destination: DashboardView(orderManager: orderManager, inventoryManager: inventoryManager))
            
            SideBarButton(.shoppingList, destination: ShoppingListView())

        }
        .padding(.horizontal, 15)
        .padding(.vertical, 20)
        .padding(.top, safeArea.top)
        .padding(.bottom, safeArea.bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .environment(\.colorScheme, .dark)
    }
    
    @ViewBuilder
    func SideBarButton<Destination: View>(_ tab: Tab, destination: Destination) -> some View {
        NavigationLink(
            destination: AnyView(destination),
            label: {
                HStack(spacing: 12) {
                    Image(systemName: tab.rawValue)
                        .font(.title3)
//                        .padding()
                    
                    Text(tab.title)
                        .font(.headline)
//                        .padding()
                    
//                    Spacer(minLength: 0)
                }
//                .padding(.vertical, 10)
//                .contentShape(RoundedRectangle(cornerRadius: 15))
//                .buttonBorderShape(.roundedRectangle(radius: 15))
                .foregroundStyle(.white)
                .background(Color.accentColor.edgesIgnoringSafeArea(.all))
                .frame(width: 200, height: 30)
                .background(in: RoundedRectangle(cornerRadius: 15))
                .padding()
            })
    }

    
    enum Tab : String, CaseIterable {
        case dashBoard = "chart.pie"
        case shoppingList = "cart"
        
        var title: String {
            switch self {
            case .dashBoard: return "Dashboard"
            case .shoppingList: return "Shopping List"

            }
        }

    }
    
    func deleteOrder(orderID: String) {
        orderManager.removeOrder(with: orderID)
    }
    
    func refreshUpcomingOrders() async {
        orderManager.fetchOrders()
        AppManager.shared.fetchCurrencyFromDB()
    }
}

#Preview {
    UpcomingOrders(orderManager: OrderManager.shared, inventoryManager: InventoryManager.shared)
}
