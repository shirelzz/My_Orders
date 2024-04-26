//
//  NotificationsDatabaseManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/04/2024.
//

import Foundation

class NotificationsDatabaseManager: DatabaseManager {
    
    static var shared = NotificationsDatabaseManager()
    
    // MARK: - Reading data
    
    func fetchNotificationSettings(path: String, completion: @escaping (Notifications) -> ()) {
        
        let notificationsRef = databaseRef.child(path)
        
        notificationsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let value = snapshot.value as? [String: Any],
                  let daysBeforeOrderTime = value["daysBeforeOrderTime"] as? Int,
                  let inventoryQuantityThreshold = value["inventoryQuantityThreshold"] as? Int
            else {
                print("No notification settings data found")
                completion(Notifications(daysBeforeOrderTime: 1, inventoryQuantityThreshold: 0))
                return
            }
            
            let notificationSettings = Notifications(
                daysBeforeOrderTime: daysBeforeOrderTime,
                inventoryQuantityThreshold: inventoryQuantityThreshold
            )
            
            completion(notificationSettings)
        })
    }
    
    // MARK: - Writing data
    
    func saveNotificationSettings(_ notificationSettings: Notifications, path: String) {
        let notificationSettingsRef = databaseRef.child(path)
        notificationSettingsRef.setValue(notificationSettings.dictionaryRepresentation())
    }
}
