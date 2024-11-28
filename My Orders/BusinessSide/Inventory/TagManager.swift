//
//  TagManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 03/05/2024.
//

import Foundation
import FirebaseAuth

class TagManager: ObservableObject {
    
    static var shared = TagManager()
    @Published var tags: [String] = []
    private var isUserSignedIn = HelperFunctions.isUserSignedIn()
    
    init() {
        if isUserSignedIn{
            fetchTagsFromDB()
        }
//        else{
//            loadItemsFromUD()
//        }
    }

    func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
            saveTag2DB(tag)
        }
    }
    
    func removeTag(_ tag: String) {
        if let index = tags.firstIndex(of: tag) {
            tags.remove(at: index)
            deleteTagFromDB(tag: tag)
        }
    }
    
    func removeTag(at index: Int) {
        if index >= 0 && index < tags.count {
            tags.remove(at: index)
        }
    }
    
    func fetchTagsFromDB() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/tags"

            TagsDatabaseManager.shared.fetchTags(path: path, completion: { fetchedTags in
                DispatchQueue.main.async {
                    self.tags = fetchedTags
                    print("Success fetching tags")
                }
            })
        }
    }
    
    func saveTag2DB(_ tag: String) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/tags"
            TagsDatabaseManager.shared.saveTag(tag, path: path)
        }
    }
    
    func deleteTagFromDB(tag: String) {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let path = "users/\(userID)/tags"
            TagsDatabaseManager.shared.deleteTag(tag: tag, path: path)
        }
    }

}
