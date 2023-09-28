//
//  FileManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 28/09/2023.
//

import Foundation

func saveOrders(_ orders: [DessertOrder]) {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let archiveURL = documentsDirectory.appendingPathComponent("orders.dat")
    
    do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: orders, requiringSecureCoding: false)
        try data.write(to: archiveURL)
    } catch {
        print("Error saving orders: \(error)")
    }
}

func loadOrders() -> [DessertOrder]? {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let archiveURL = documentsDirectory.appendingPathComponent("orders.dat")
    
    if let data = try? Data(contentsOf: archiveURL) {
        do {
            let orders = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [DessertOrder]
            return orders
        } catch {
            print("Error loading orders: \(error)")
        }
    }
    
    return nil
}

