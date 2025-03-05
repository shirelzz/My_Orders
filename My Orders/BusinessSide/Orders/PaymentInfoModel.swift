//
//  PaymentInfoModel.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/02/2025.
//

import Foundation

enum PaymentMethod: String, CaseIterable, Codable {
    case paymentApp = "Payment App"
    case bankTransfer = "Bank transfer"
    case cash = "Cash"
    case cheque = "Cheque"
}

struct PaymentInfoModel: Codable, Hashable {
    var method: PaymentMethod
    var details: String
    var date: Date
    var paymentApp: String?
    
    // Default constructor
    init(method: PaymentMethod = .paymentApp, details: String = "", date: Date = Date(), paymentApp: String? = "")
    {
        self.method = method
        self.details = details
        self.date = date
        self.paymentApp = paymentApp
    }
    
    func dictionaryRepresentation() -> [String: Any] {
        let dateFormatter = DateFormatter()
              dateFormatter.dateFormat = "yyyy-MM-dd"

        return [
            "method": method.rawValue,
            "details": details,
            "date": dateFormatter.string(from: date),
            "paymentApp": paymentApp ?? ""
        ]
    }
    
    init?(dictionary: [String: Any]) {
        
        guard let methodString = dictionary["method"] as? String,
              let method = PaymentMethod(rawValue: methodString),
              let details = dictionary["details"] as? String,
              let date = dictionary["date"] as? Date,
              let paymentApp = dictionary["paymentApp"] as? String
        else {
            return nil
        }
        self.method = method
        self.details = details
        self.date = date
        self.paymentApp = paymentApp

    }

}

