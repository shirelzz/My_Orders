//
//  ContentView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var orderManager = OrderManager.shared
    
    @State private var showAllOrders = false
    @State private var showAllReceipts = false
    @State private var isAddOrderViewPresented = false // This controls the navigation
    
    
    init() {
        // Load orders from UserDefaults when ContentView is initialized
        OrderManager.shared.loadOrders()
    }
    
    var body: some View {
        
        NavigationStack {
            
            List {
                Button(action: {
                    isAddOrderViewPresented = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.blue)
                        .padding()
                        .shadow(radius: 2)
                }
                .padding()
                .sheet(isPresented: $isAddOrderViewPresented) {
                    AddOrderView(orderManager: orderManager)
                }
                
                List {
                    ForEach(upcomingOrders, id: \.orderID) { order in
                        NavigationLink(destination: OrderDetailsView(order: order)) {
                            OrderRowView(order: order)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
                
                HStack{
                    
                    Button(action: {
                        showAllReceipts = true // Activate navigation
                    }) {
                        HStack {
                            Text("All Receipts")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .navigationDestination(isPresented: $showAllReceipts) {
                        AllReceiptsView(orderManager: orderManager)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        self.showAllOrders = true
                    }) {
                        HStack {
                            Text("All Orders")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .navigationDestination(isPresented: $showAllOrders) {
                        AllOrdersView(orderManager: orderManager)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                }

                
            }
            .navigationBarTitle("Upcoming Orders")
        }
        .accentColor(.blue)
        .onAppear {
            orderManager.orders.sort { $0.orderDate > $1.orderDate }
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
