//
//  AllOrdersView.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//
import SwiftUI

struct AllOrdersView: View {
    @ObservedObject var orderManagement: OrderManager

    var body: some View {
        List(orderManagement.getOrders()) { order in
            NavigationLink(destination: OrderDetailsView(order: order)) {
                OrderRowView(order: order)
            }
        }
        .navigationBarTitle("All Orders")
    }
}


struct AllOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        AllOrdersView(orderManagement: OrderManager.shared)
    }
}
