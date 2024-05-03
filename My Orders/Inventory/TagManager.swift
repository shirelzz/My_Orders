//
//  TagManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 03/05/2024.
//

import Foundation

class TagManager: ObservableObject {
    static var shared = TagManager()
    @Published var tags: [String] = []
    
    func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
        }
    }
    
    func removeTag(_ tag: String) {
        if let index = tags.firstIndex(of: tag) {
            tags.remove(at: index)
        }
    }
    
    func removeTag(at index: Int) {
        if index >= 0 && index < tags.count {
            tags.remove(at: index)
        }
    }
}
