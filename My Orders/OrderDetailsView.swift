//
//  OrderDetailsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import SwiftUI

struct OrderDetailsView: View {
    
    let order: DessertOrder
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long // Choose the desired date style
        formatter.timeStyle = .short // Choose the desired time style
        return formatter
    }()
    
    var body: some View {
        VStack (alignment: .leading){
            
            HStack {
                Text(" Name:")
                    .bold()
                Text(order.customer.name)
            }
            HStack {
                Text(" Phone number: ")
                    .bold()
                Text("0" + String(order.customer.phoneNumber))
            }
            HStack {
                Text(" Order time:")
                    .bold()
                Text(dateFormatter.string(from: order.orderDate))
            }
            HStack {
                Text(" Delivery:")
                    .bold()
                Text(order.delivery.address)
            }


            // Display a list of desserts in the order
            Section(header: Text("Order Information")) {
                
                List(order.desserts, id: \.dessertName) { dessert in
                    HStack {
                        Text("\(dessert.dessertName)")
                        Spacer()
                        Text("Q: \(dessert.quantity)")
                        Text(" ₪\(dessert.price, specifier: "%.2f")")
                    }
                }
            }
            
            Section(header: Text("More Information")) {
                HStack {
                    Text("Notes:")
                        .bold()
                    Text(order.notes)
                }
                HStack {
                    Text("Allergies:")
                        .bold()
                    Text(order.allergies)
                }
            }
            
            
            Section(header: Text("Order Status")) {
                Toggle("Completed", isOn: Binding<Bool>(
                    get: { order.isCompleted },
                    set: { newValue in
                        OrderManager.shared.updateOrderStatus(orderID: order.id, isCompleted: newValue)
                    }
                ))
            }

            
            Text("Delivery: \(order.delivery.cost, specifier: "%.2f")")
            Text("Total Price: ₪\(order.totalPrice, specifier: "%.2f")")

        }
        .navigationBarTitle("Order Details")
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
            notes: "None",
            allergies: "None",
            isCompleted: false
        )
        
        return OrderDetailsView(order: sampleOrder)
    }
}
