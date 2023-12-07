//
//  DashboardView.swift
//  My Orders
//
//  Created by שיראל זכריה on 07/12/2023.
//

import SwiftUI
import SwiftUICharts

struct DashboardView: View {
    
    @ObservedObject var orderManager: OrderManager
    @ObservedObject var inventoryManager: InventoryManager

    
//    var filteredOrders: [Order] {
//        return orderManager.orders.filter { order in
//            let receiptYear = Calendar.current.component(.year, from: receipt.dateGenerated)
//            return receiptYear == selectedYear
//        }
//    }
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Income Review
                    VStack(alignment: .leading) {
                        Text("Income Review")
                            .font(.title)
                            .fontWeight(.bold)

                        let thisWeekIncome = calculateThisWeekIncome()
                        Text("This Week's Income: $\(thisWeekIncome, specifier: "%.2f")")
                            .font(.headline)
                    }
                    .padding()
                    
                    // Yearly Income Graph (Bar Chart)
                    VStack(alignment: .leading) {
                        Text("Yearly Income Graph")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        let yearlyIncomeData = calculateYearlyIncome()
                        BarChartView(data: ChartData(values: yearlyIncomeData), title: "Monthly Income", legend: "Monthly", style: Styles.barChartStyleOrangeLight)
                            .frame(height: 200)
                    }
                    .padding()
                    
                    // Most Ordered Inventory Items (Bar Chart)
                    VStack(alignment: .leading) {
                        Text("Most Ordered This Week")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        let mostOrderedItems = calculateMostOrderedItems()
                        BarChartView(data: ChartData(values: mostOrderedItems.map { ($0.0, Double($0.1)) }), title: "Most Ordered", legend: "Items", style: Styles.barChartStyleOrangeLight)
                            .frame(height: 200)

//                        BarChartView(data: ChartData(values: mostOrderedItems.map { Double($0.1) }), title: "Most Ordered", legend: "Items", style: Styles.barChartStyleNeonBlueLight)
//                            .frame(height: 200)
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Dashboard")
        }
    
    // Helper functions to calculate data
    
//    private func calculateMostOrderedItems() -> [(String, Int)] {
//        let thisWeekOrders = getThisWeekOrders()
//            
//            // Create a dictionary to store the count of each item
//            var itemCounts: [String: Int] = [:]
//            
//            // Iterate over each order and update the item count
//            for order in thisWeekOrders {
//                for dessert in order.desserts {
//                    let itemName = dessert.inventoryItem.name
//                    itemCounts[itemName, default: 0] += dessert.quantity
//                }
//            }
//            
//            // Convert the dictionary to an array of tuples and sort by order count
//            let mostOrderedItems = itemCounts.sorted { $0.value > $1.value }
//            
//            return mostOrderedItems
//    }
    private func calculateMostOrderedItems() -> [(String, Double)] {
        let thisWeekOrders = getThisWeekOrders()
        
        // Create a dictionary to store the count of each item
        var itemCounts: [String: Double] = [:]
        
        // Iterate over each order and update the item count
        for order in thisWeekOrders {
            for dessert in order.desserts {
                let itemName = dessert.inventoryItem.name
                itemCounts[itemName, default: 0.0] += Double(dessert.quantity)
            }
        }
        
        // Convert the dictionary to an array of tuples and sort by order count
        let mostOrderedItems = itemCounts.sorted { $0.value > $1.value }
        
        return mostOrderedItems
    }

    
    private func calculateThisWeekIncome() -> Double {
        let filteredOrders = getThisWeekOrders()
        var sum = 0.0

        for order in filteredOrders {
            sum += order.totalPrice
        }
        return sum
    }
    
    private func calculateYearlyIncome() -> [(String, Double)] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        
        var yearlyIncome: [(String, Double)] = []

        for month in 1...12 {
            let formattedMonth = String(format: "%02d", month)
            let monthlyIncome = calculateMonthlyIncome(month: formattedMonth)
            yearlyIncome.append((formattedMonth, monthlyIncome))
        }

        return yearlyIncome
    }
    
    private func calculateMonthlyIncome(month: String) -> Double {
        let filteredOrders = getMonthlyOrders(month: month)
        var sum = 0.0

        for order in filteredOrders {
            sum += order.totalPrice
        }
        return sum
    }
    
    private func getThisWeekOrders() -> [Order] {
            let currentDate = Date()
            let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
            let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek)!
            
            let filteredOrders = orderManager.getOrders().filter { order in
                return startOfWeek <= order.orderDate && order.orderDate <= endOfWeek
            }
            
            return filteredOrders
    }
    
    private func getMonthlyOrders(month: String) -> [Order] {
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM"
            
            let filteredOrders = orderManager.getOrders().filter { order in
                let orderMonth = dateFormatter.string(from: order.orderDate)
                return orderMonth == month
            }
            
            return filteredOrders
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(orderManager: OrderManager.shared, inventoryManager: InventoryManager.shared)
    }
}
