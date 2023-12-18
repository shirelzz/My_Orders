//
//  NotificationsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 27/11/2023.
//

import SwiftUI

struct NotificationsView: View {
    
    @State private var receiveOrderTimeNotification = UserDefaults.standard.bool(forKey: "ReceiveOrderTimeNotification")
    @State private var receiveInventoryNotification = UserDefaults.standard.bool(forKey: "ReceiveInventoryNotification")
    
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Receive order time notifications", isOn: $receiveOrderTimeNotification)
                    .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))

                Toggle("Receive inventory notifications", isOn: $receiveInventoryNotification)
                    .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))

            }
        }
        .navigationBarTitle("Notification Settings")
        .onChange(of: receiveOrderTimeNotification) { _ in saveNotificationSettings() }
        .onChange(of: receiveInventoryNotification) { _ in saveNotificationSettings() }
    }
    
    private func saveNotificationSettings() {
        UserDefaults.standard.set(receiveOrderTimeNotification, forKey: "ReceiveOrderTimeNotification")
        UserDefaults.standard.set(receiveInventoryNotification, forKey: "ReceiveInventoryNotification")
        
        // Add any additional logic you need for handling notification settings here.
    }
}



#Preview {
    NotificationsView()
}
