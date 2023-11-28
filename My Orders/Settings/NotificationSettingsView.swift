//
//  NotificationSettingsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 27/11/2023.
//

import SwiftUI

struct NotificationSettingsView: View {
    
    @State private var notifyOrderTime = true
    @State private var orderTimeDaysBefore = 1

    @State private var notifyInventory = true
    @State private var inventoryThreshold = 10

    var body: some View {
        
        Form {
            
            Section(header: Text("Order Time Notifications")) {
                Toggle("Notify me before order time", isOn: $notifyOrderTime)
                if notifyOrderTime {
                    Stepper("Days: \(orderTimeDaysBefore)", value: $orderTimeDaysBefore, in: 1...30)
                }
            }

            Section(header: Text("Inventory Notifications")) {
                Toggle("Notify me for low inventory", isOn: $notifyInventory)
                if notifyInventory {
                    Stepper("Quantity: \(inventoryThreshold)", value: $inventoryThreshold, in: 1...100)
                }
            }
            
        }
        .navigationBarTitle("Notification Settings")
    }
}


#Preview {
    NotificationSettingsView()
}
