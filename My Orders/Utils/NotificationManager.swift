//
//  NotificationManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 10/01/2024.
//

import Foundation
import UserNotifications
import FirebaseAuth

struct Notifications : Codable {
    
    var daysBeforeOrderTime: Int
    var inventoryQuantityThreshold: Int
    
    func dictionaryRepresentation() -> [String: Any] {
        return [
            "daysBeforeOrderTime": daysBeforeOrderTime,
            "inventoryQuantityThreshold": inventoryQuantityThreshold
        ]
    }
}

class NotificationManager: ObservableObject {
    
    static var shared = NotificationManager()
    var notificationSettings: Notifications
    private var isUserSignedIn = Auth.auth().currentUser != nil
    
    init() {
        
        self.notificationSettings = Notifications(daysBeforeOrderTime: 0, inventoryQuantityThreshold: 0)
        self.isUserSignedIn = Auth.auth().currentUser != nil
        
        if isUserSignedIn{
            fetchNotificationSettings()
        }
        else {
            loadNotificationSettingsFromUD()
        }
    }
    
    func saveNotificationSettings(notifications: Notifications) {
        notificationSettings = notifications
        if isUserSignedIn {
            saveNotificationSettings2DB(notifications)
        }
        else{
            saveNotificationSettingsToUD()
        }
    }
    
    // MARK: - Database

    func fetchNotificationSettings() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/notificationSettings"

            NotificationsDatabaseManager.shared.fetchNotificationSettings(path: path, completion: { fetchedNotificationSettings in

                DispatchQueue.main.async {
                    self.notificationSettings = fetchedNotificationSettings
                    print("Success fetching notificationSettings")
                }
            })
        }
    }
    
    func saveNotificationSettings2DB(_ notifications: Notifications) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/notificationSettings"
            NotificationsDatabaseManager.shared.saveNotificationSettings(notifications, path: path)
        }
    }
    
    // MARK: - User Defaults
    
    func loadNotificationSettingsFromUD() {
           if let data = UserDefaults.standard.data(forKey: "notificationSettings") {
               do {
                   let decodedSettings = try JSONDecoder().decode(Notifications.self, from: data)
                   self.notificationSettings = decodedSettings
                   print("Notification settings loaded from User Defaults")
               } catch {
                   print("Error decoding notification settings: \(error.localizedDescription)")
               }
           }
       }

    func saveNotificationSettingsToUD() {
        do {
            let encodedSettings = try JSONEncoder().encode(notificationSettings)
            UserDefaults.standard.set(encodedSettings, forKey: "notificationSettings")
            print("Notification settings saved to User Defaults")
        } catch {
            print("Error encoding notification settings: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Inventory Notifications
    
    func scheduleInventoryNotification(item: InventoryItem, notifyWhenQuantityReaches: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Inventory Alert"
        content.body = "\(item.name) is running low. Current quantity: \(item.itemQuantity)"
        
        let triggerQuantity = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)  // Set to 1 second for testing purposes, adjust as needed
        
        let request = UNNotificationRequest(identifier: item.itemID, content: content, trigger: triggerQuantity)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling inventory notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Order Notifications
    
    func scheduleOrderNotification(order: Order) {
        let content = UNMutableNotificationContent()
        content.title = "Order Time is Soon"
        content.body = "Your order \(order.orderID) is coming up in \(notificationSettings.daysBeforeOrderTime) days."
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.date(byAdding: .day, value: -notificationSettings.daysBeforeOrderTime, to: order.orderDate) ?? Date()
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: order.orderID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

}
