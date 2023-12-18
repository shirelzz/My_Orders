////
////  ReviewView.swift
////  My Orders
////
////  Created by שיראל זכריה on 07/12/2023.
////
//
//import SwiftUI
//
//struct ReviewView: View {
//    @ObservedObject var orderManager: OrderManager
//
//    var body: some View {
//            VStack {
//                Text("Income this week: $\(weeklyIncome, specifier: "%.2f")")
//                    .font(.headline)
//                
//                // Additional content related to most ordered items can be added here
//            
//        
//                    Text("Most Ordered Items:")
//                        .font(.headline)
//                    
//                    // Display the most ordered items here
//                    ForEach(mostOrderedItems, id: \.self) { item in
//                        Text("\(item.name): \(item.totalOrderedQuantity)")
//                    }
//                }
//            .navigationBarTitle("Overview")
//
//        }
//    
//    
//    private var weeklyIncome: Double {
//            let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
//            let ordersThisWeek = orderManager.getOrders(in: startDate...Date())
//            return ordersThisWeek.reduce(0) { $0 + $1.totalPrice }
//        }
//    
//    private var mostOrderedItems: [InventoryItem] {
//            let allOrders = orderManager.getOrders()
//            
//            // Dictionary to store the quantity of each inventory item
//            var itemQuantityDictionary: [InventoryItem: Int] = [:]
//            
//            // Calculate the quantity of each item
//            for order in allOrders {
//                for dessert in order.desserts {
//                    let item = dessert.inventoryItem
//                    itemQuantityDictionary[item, default: 0] += dessert.quantity
//                }
//            }
//            
//            // Sort items based on quantity in descending order
//            let sortedItems = itemQuantityDictionary.sorted { $0.value > $1.value }
//            
//            // Return the most ordered items
//            return sortedItems.map { $0.key }
//        }
//}
//
//#Preview {
//    ReviewView(orderManager: OrderManager.shared)
//}
