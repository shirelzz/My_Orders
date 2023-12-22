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
    
    @State var mostOrderedPeriod = "Week"
    
    var body: some View {
        
            ScrollView {
                
                VStack(alignment: .leading, spacing: 10) {
                    // Income Review
                    Section(header: Text("Income Review")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading)
                    ) {

                        let thisWeekIncome = calculateThisWeekIncome()
                        let numOrders = getThisWeekOrders().count

                        Text("This Week's Income: $\(thisWeekIncome, specifier: "%.2f")")                .padding(.leading)

                        Text("Number of Orders This Week: \(numOrders, specifier: "%.2f")")                .padding(.leading)

                    }
                    .padding(.trailing)

                    Section(header: Text("Yearly Income Graph")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.leading)
                    ) {
                        let yearlyIncomeData = calculateYearlyIncome()
                        BarChartView(data: ChartData(values: yearlyIncomeData),
                                     title: "Monthly Income", legend: "Monthly",
                                     style: Styles.barChartStyleOrangeLight,
                                     form: ChartForm.extraLarge)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.trailing)

                    Section(header: Text("Most Ordered")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading)
                    ) {
                        Picker("", selection: $mostOrderedPeriod) {
                            Text("Month").tag("Month").cornerRadius(10.0)
                            Text("Week").tag("Week").cornerRadius(10.0)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .background(Color.accentColor.opacity(0.3))
                        .cornerRadius(10.0)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width / 3)
                        
                        let mostOrderedItems = calculateMostOrderedItems(period: mostOrderedPeriod)
                        BarChartView(data: ChartData(values: mostOrderedItems.map { ($0.0, Double($0.1)) }),
                                     title: "Most Ordered",
                                     legend: "Items",
                                     style: Styles.barChartStyleOrangeLight,
                                     form: ChartForm.extraLarge)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width)
                    }
                    .padding(.trailing)
                    
                    
                }
                .padding(.leading)

                }
            .navigationBarTitle("Dashboard")

            
//            .background(Color.accentColor.opacity(0.2))
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
    
    private func calculateMostOrderedItems(period: String) -> [(String, Double)] {
        var orders: [Order]
        if period == "month"{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM"
            let currentMonth = dateFormatter.string(from: Date())
            orders = getMonthlyOrders(month: currentMonth)
        }
        else {
            orders = getThisWeekOrders()
        }
        
        // Create a dictionary to store the count of each item
        var itemCounts: [String: Double] = [:]
        
        // Iterate over each order and update the item count
        for order in orders {
            for dessert in order.orderItems {
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
