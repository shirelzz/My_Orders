//
//  HelperFunctions.swift
//  My Orders
//
//  Created by שיראל זכריה on 25/01/2024.
//

import Foundation
import SwiftUI


class HelperFunctions {
    
    static func isDarkMode() -> Bool {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.traitCollection.userInterfaceStyle == .dark
        }
        return false
    }
    
    static func closeKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    static func getWidth() -> CGFloat {
        let width = UIScreen.main.bounds.width - 32
        return width
    }
    
    static func getHeight() -> CGFloat {
        let height = UIScreen.main.bounds.height - 32
        return height
    }
    
    static func formatToDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
    
    static func formatToDateAndTimeShort(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    static func getCurrencySymbol() -> String {
        return AppManager.shared.getCurrencySymbol()
    }
}
