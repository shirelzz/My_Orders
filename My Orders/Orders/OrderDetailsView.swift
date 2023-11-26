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
    @State private var showReceiptPreview = false
    
    var isReceiptExists: Bool {
        return OrderManager.shared.receiptExists(forOrderID: order.orderID)
    }
    
    var flag = false
    
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Section(header: Text("Customer Information")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top)
            ) {
                Text("Name: \(order.customer.name)")
                Text("Phone: 0\(String(order.customer.phoneNumber))")
            }
            
            Section(header: Text("Order Information")
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

                Text("Order Date: \(order.orderDate.formatted())")
                
            }
            
            if (order.delivery.address != "" || order.notes != "" || order.allergies != "") {
                Section(header:
                            Text("Additional Details")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.top)
                ) {
                    
                    if(order.delivery.address != ""){
                        Text("Delivery Address: \(order.delivery.address)")
                    }
                    
                    if(order.notes != ""){
                        Text("Notes: \(order.notes)")
                    }
                
                    if(order.allergies != ""){
                        Text("Notes: \(order.allergies)")
                    }
                    
                }
            }
            
            Section(header:
                        Text("Order Status")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top)
            ) {
                Toggle("Completed", isOn: $order.isCompleted)
//                    .disabled(OrderManager.shared.receiptExists(forOrderID: order.orderID))
                    .onChange(of: order.isCompleted) { newValue in
                        if !flag{
                            
                            OrderManager.shared.updateOrderStatus(orderID: order.id, isCompleted: newValue)
                        }

                }
                
                if order.isCompleted {
                    Button("Show Receipt Preview") {
                        showReceiptPreview = true
                    }
                    .sheet(isPresented: $showReceiptPreview) {
                        NavigationView {
                            ReceiptView(order: order, isPresented: $showReceiptPreview)
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
                
                if(order.delivery.cost != 0){
                    Text("Delivery Cost: ₪\(order.delivery.cost, specifier: "%.2f")")
                }
                
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
