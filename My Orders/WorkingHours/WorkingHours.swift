//
//  WorkingHours.swift
//  Confetti
//
//  Created by שיראל זכריה on 14/02/2024.
//

import Foundation

struct WorkingDay: Identifiable, Codable, Hashable{
    
    var id: String
    let day: String
    var from: Date
    var to: Date
    
    init(day: String) {
        self.id = UUID().uuidString
        self.day = day
        
        // Create a calendar instance
        let calendar = Calendar.current
        
        // Create date components for 08:00
        var fromComponents = DateComponents()
        fromComponents.hour = 8
        fromComponents.minute = 0
        
        // Create a date object for 08:00
        self.from = calendar.date(from: fromComponents) ?? Date()
        
        // Create date components for 16:00
        var toComponents = DateComponents()
        toComponents.hour = 16
        toComponents.minute = 0
        
        // Create a date object for 16:00
        self.to = calendar.date(from: toComponents) ?? Date()
    }
    
    init(day: String, from: Date, to: Date) {
        self.id = UUID().uuidString
        self.day = day
        self.from = from
        self.to = to
    }
    
    init(id: String, day: String, from: Date, to: Date) {
        self.id = id
        self.day = day
        self.from = from
        self.to = to
    }
    
    func dictionaryRepresentation() -> [String: Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let workingDayDict: [String: Any] = [
            
            "id": id,
            "day": day,
            "from": dateFormatter.string(from: from),
            "to": dateFormatter.string(from: to)
        ]
        
        return workingDayDict
    }
    
    init?(dictionary: [String: Any]) {
        
        guard let id = dictionary["id"] as? String,
              let day = dictionary["day"] as? String,
              let from = dictionary["from"] as? Date,
              let to = dictionary["to"] as? Date
        else {
            return nil
        }
        self.id = id
        self.day = day
        self.from = from
        self.to = to
        
    }
}


