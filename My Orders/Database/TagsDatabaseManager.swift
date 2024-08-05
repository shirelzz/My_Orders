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
        
        tagsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let tagsData = snapshot.value as? [String: String] else {

            print("No tags found")
                completion([])
                return
            }
            
            // Extract the tags from the snapshot value
            let tags = Array(tagsData.values).sorted()
             print("tags yes: ", tags)

            // Call the completion handler with the fetched tags
            completion(tags)
        })
    }
        
    func saveTag(_ tag: String, path: String) {
        let tagRef = databaseRef.child(path).childByAutoId() // Generate a unique key for the new tag
        tagRef.setValue(tag)
    }
    
    // MARK: - Deleting data
    
    func deleteTag(tag: String, path: String) {
        let tagsRef = databaseRef.child(path)
        
        // Find the key associated with the tag
        tagsRef.observeSingleEvent(of: .value) { snapshot in
            guard let tagsData = snapshot.value as? [String: String] else {
                print("No tags found")
                return
            }
            
            if let tagKey = tagsData.first(where: { $0.value == tag })?.key {
                // Delete the tag by its key
                tagsRef.child(tagKey).removeValue { error, _ in
                    if let error = error {
                        print("Error removing tag: \(error.localizedDescription)")
                    } else {
                        print("Tag removed successfully")
                    }
                }
            } else {
                print("Tag not found")
            }
        }
    }

}
