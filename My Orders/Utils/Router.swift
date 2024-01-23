////
////  Router.swift
////  My Orders
////
////  Created by שיראל זכריה on 14/01/2024.
////
//
//import Foundation
//
//public enum Routes: Equatable, Hashable {
//    case welcome, userRole, vendorType, bussinessDetailsView, contentView, customerContent
//    case none
//    
//    public static func == (lhs: Routes, rhs: Routes) -> Bool {
//        switch (lhs, rhs) {
//        case(.welcome, .welcome),
//            (.userRole, .userRole),
//            (.vendorType, .vendorType),
//            (.bussinessDetailsView, .bussinessDetailsView),
//            (.contentView, .contentView),
//            (.customerContent, .customerContent),
//            (.none, .none):
//            return true
//            
//        default:
//            return false
//        }
//    }
//}
//
//public struct RoutePath: Hashable {
//    public var route: Routes = .none
//    var hashValue = { UUID().uuid }
//    public init(_ route: Routes) {
//        self.route = route
//    }
//
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(hashValue)
//    }
//
//    public static func == (lhs: RoutePath, rhs: RoutePath) -> Bool {
//        lhs.route == rhs.route
//    }
//}
//
//public class Router: ObservableObject {
//    public static var shared: Router = Router()
//    
//    public var changeRoute: ((RoutePath) -> Void)!
//    public var backRoute: (() -> Void)!
//}
