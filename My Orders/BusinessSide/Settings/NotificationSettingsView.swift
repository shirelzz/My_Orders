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
                    .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                
                if notifyOrderTime {
                    Stepper("Days: \(orderTimeDaysBefore)", value: $orderTimeDaysBefore, in: 1...30)
                }
            }
            
            Section(header: Text("Inventory Notifications")) {
                Toggle("Notify me for low inventory", isOn: $notifyInventory)
                    .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                
                if notifyInventory {
                    Stepper("Quantity: \(inventoryThreshold)", value: $inventoryThreshold, in: 1...100)
                    
                }
                
            }

        }
        .navigationBarTitle("Notification Settings")
        .onChange(of: orderTimeDaysBefore) { _ in
            saveNotificationSettings()
        }
        .onChange(of: inventoryThreshold) { _ in
            saveNotificationSettings()
        }

    }
    
    private func saveNotificationSettings() {
        NotificationManager.shared.saveNotificationSettings(notifications: Notifications(daysBeforeOrderTime: orderTimeDaysBefore, inventoryQuantityThreshold: inventoryThreshold))
    }
}

#Preview {
    NotificationSettingsView()
}
