//
//  CurrencyDatabaseManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/04/2024.
//

import Foundation

class CurrencyDatabaseManager: DatabaseManager {
    
    static var shared = CurrencyDatabaseManager()
    
    // MARK: - Reading data
    
    func fetchCurrency(path: String, completion: @escaping (String) -> ()) {
        
        let currencyRef = databaseRef.child(path)
        
        currencyRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let currency = snapshot.value as? String else {
                print("No currency data found")
                completion("USD")
                return
            }
            
            completion(currency)
        })
    }
    
    // MARK: - Writing data
    
    func saveCurrency(_ currency: String, path: String) {
        let currencyRef = databaseRef.child(path)
        currencyRef.setValue(currency) { error, _ in
            if let error = error {
                print("Error saving currency: \(error.localizedDescription)")
            } else {
                print("Currency saved successfully")
            }
        }
    }
    
}
