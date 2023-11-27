//
//  ContentView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var appManager = AppManager.shared
    @StateObject private var orderManager = OrderManager.shared

    
//    @StateObject private var inventoryManager = InventoryManager.shared

    @State private var showAllOrders = false
    @State private var showAllReceipts = false
    @State private var isAddOrderViewPresented = false
    
    
    init() {
        // Load orders from UserDefaults when ContentView is initialized
        OrderManager.shared.loadOrders()
    }
    
    
    var body: some View {
        
        NavigationStack{
            
//            Image(uiImage: UIImage(data: appManager.manager.logoImgData ?? Data()) ?? UIImage())
//                .resizable(capInsets: EdgeInsets())
//                .frame(width: 50, height: 50)
//                .cornerRadius(10)
//                .padding(.leading, 150.0)
            
            
            ZStack(alignment: .topTrailing) {
                
                
                VStack (alignment: .trailing, spacing: 10) {
                    
                    HStack {
                        
                        Spacer()

                        Text("Upcoming Orders")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        Spacer()
                        
                        Button(action: {
                            isAddOrderViewPresented = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.blue)
                                .padding()
                                .shadow(radius: 1)
                        }
                        .sheet(isPresented: $isAddOrderViewPresented) {
                            AddOrderView(orderManager: orderManager)
                        }
                        

                    }
                                    
                    if upcomingOrders.isEmpty {
                        Text("No upcoming orders")
                            .font(.headline)
                            .padding()
                            
                    } else {
                        List {
                            ForEach(upcomingOrders, id: \.orderID) { order in
                                NavigationLink(destination: OrderDetailsView(order: order)) {
                                    OrderRowView(order: order)
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(.plain) 
                    }
                    
//                    AdBannerView()
//                                       .frame(width: UIScreen.main.bounds.width, height: 50)
//                                       .background(Color.gray) // Optional background color
                }
                
            }
                        
        
            .toolbar {
                
                    ToolbarItem(placement: .navigationBarLeading) {
                        
                        Menu {
        
                            HStack {
                                NavigationLink(destination: AllOrdersView(orderManager: orderManager)) {
                                     Label("All orders", systemImage: "rectangle.stack")
                                }
                            }
                            
                            HStack {
                                NavigationLink(destination: AllReceiptsView(orderManager: orderManager)) {
                                     Label("All receipts", systemImage: "tray.full")
                                }
                            }
                            
                            HStack {
                                NavigationLink( destination: InventoryContentView()) {
                                     Label("Inventory", systemImage: "cube")
                                }
                            }
                            
                            HStack {
                                NavigationLink(destination: SettingsView()) {
                                    Label("Settings", systemImage: "gear")
                                    }
                            }
                            

                            
                        } label: {
                            Image(systemName: "line.horizontal.3")
                        }
                    }
                }
        }
        
    }
    
    var upcomingOrders: [DessertOrder] {
        return orderManager.orders.filter { !$0.isCompleted && $0.orderDate > Date()}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//#Preview {
//    ContentView2()
//}
