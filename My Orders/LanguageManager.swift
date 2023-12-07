//
//  LanguageManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 30/11/2023.
//

import Foundation
import SwiftUI

//enum AppLanguage: String {
//    case english = "en"
//    case hebrew = "he"
//    
//    static let defaultLanguage = AppLanguage.english
//}

enum AppLanguage: String , CaseIterable{
    case english = "English"
    case hebrew = "Hebrew"
    
    var layoutDirection: LayoutDirection {
        return (self == .hebrew) ? .rightToLeft : .leftToRight
    }

}



class LanguageManager: ObservableObject {
    
    static let shared = LanguageManager()
    @Published var currentLanguage: AppLanguage = .english


    private init() {}
    


//    var currentLanguage: AppLanguage {
//        get {
//            if let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage"),
//               let language = AppLanguage(rawValue: savedLanguage) {
//                return language
//            }
//            // Default to English if no language is set
//            return .english
//        }
//        set {
//            UserDefaults.standard.set(newValue.rawValue, forKey: "appLanguage")
//        }
//    }
    
    func getCurrentLanguage() -> String {
        return currentLanguage.rawValue
    }
}
