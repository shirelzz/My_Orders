//
//  TagsDatabaseManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 03/05/2024.
//

import Foundation

class TagsDatabaseManager: DatabaseManager {
    
    static var shared = TagsDatabaseManager()
    
    // MARK: - Reading data
    
    func fetchTags(path: String, completion: @escaping ([String]) -> ()) {
        let tagsRef = databaseRef.child(path)
        
        // Observe the data at the specified path once
        tagsRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let tagsData = snapshot.value as? [String] else {
                // No tags found or error in data format
                completion([])
                return
            }
            
            // Extract the tags from the snapshot value
            let tags = Array(tagsData)
            
            // Call the completion handler with the fetched tags
            completion(tags)
        }
    }
        
    func saveTag(_ tag: String, path: String) {
        let tagRef = databaseRef.child(path).childByAutoId() // Generate a unique key for the new tag
        tagRef.setValue(tag)
    }
    
    // MARK: - Deleting data
    
    func deleteTag(tag: String, path: String) {
        let tagRef = databaseRef.child(path).child(tag)
        tagRef.removeValue()
    }
}
