//
//  NavigationManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 23/01/2024.
//

import Foundation
import SwiftUI

class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    @Published var path: NavigationPath = NavigationPath()
}

final class Router: ObservableObject {
    
    public enum Destination: Codable, Hashable {
        case welcome, userRole, vendorType, businessDetailsView, contentView, customerContent
    }
    
    @Published var navPath = NavigationPath()
    
    func navigate(to destination: Destination) {
        if navPath.isEmpty {
            navPath.append(Destination.welcome)
        }
        navPath.append(destination)
    }
    
    func navigateBack() {
        navPath.removeLast()
    }
    
    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
}
