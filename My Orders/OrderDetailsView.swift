//
//  OrderDetailsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct OrderDetailsView: View {
    
    @State var order: DessertOrder
    @State private var showReceipt = false
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            Section(header:
                        Text("Customer Information")
                .font(.headline) // Apply headline font size
                .fontWeight(.bold) // Apply bold font weight
                .padding(.top)
            ) {
                Text("Name: \(order.customer.name)")
                Text("Phone: 0\(order.customer.phoneNumber)")
            }
            
            Section(header:
                        Text("Order Information")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top)
            ) {
                List(order.desserts, id: \.dessertName) { dessert in
                    HStack {
                        Text("\(dessert.dessertName)")
                        Spacer()
                        Text("Q: \(dessert.quantity)")
                        Text(" ₪\(dessert.price, specifier: "%.2f")")
                    }
                }
            }
            
            Section(header:
                        Text("Additional Details")
                .font(.headline) // Apply headline font size
                .fontWeight(.bold) // Apply bold font weight
                .padding(.top)
            ) {
                Text("Delivery Address: \(order.delivery.address)")
                Text("Notes: \(order.notes)")
                Text("Allergies: \(order.allergies)")
                
            }
            
            Section(header:
                                    Text("Order Status")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.top)
                        ) {
                            Toggle("Completed", isOn: $order.isCompleted)
                                .onChange(of: order.isCompleted) { newValue in
                                    OrderManager.shared.updateOrderStatus(orderID: order.id, isCompleted: newValue)
                                }
                            
                            Button("Generate Receipt") {
                                showReceipt.toggle() // Toggle the state variable to show/hide receipt view
                                @AppStorage("receipts") var receiptsData: Data = Data()
                                var receipts: [Receipt] {
                                    get {
                                        if let decodedReceipts = try? JSONDecoder().decode([Receipt].self, from: receiptsData) {
                                            return decodedReceipts
                                        }
                                        return []
                                    }
                                    set {
                                        if let encodedReceipts = try? JSONEncoder().encode(newValue) {
                                            receiptsData = encodedReceipts
                                        }
                                    }
                                }

                                
                            }
                        }
            
            Section(header:
                        Text("Price")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top)
            ) {
                Text("Delivery: ₪\(order.delivery.cost, specifier: "%.2f")")
                Text("Total Price: ₪\(order.totalPrice, specifier: "%.2f")")
            }
        }
        .padding()
                .navigationBarTitle("Order Details")
                .sheet(isPresented: $showReceipt) {
                    ReceiptView(order: order, isPresented: $showReceipt) // Present receipt view when the state variable is true
                }
    }
}

struct OrderDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleOrder = DessertOrder(
            orderID: "123",
            customer: Customer(name: "John Doe", phoneNumber: 0546768900),
            desserts: [Dessert(dessertName: "Chocolate Cake", quantity: 2, price: 10.0)],
            orderDate: Date(),
            delivery: Delivery(address: "yefe nof 18, peduel", cost: 10) ,
            notes: "",
            allergies: "",
            isCompleted: false
        )
        
        return OrderDetailsView(order: sampleOrder)
    }
}
