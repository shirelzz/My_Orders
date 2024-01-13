//
//  Encryption.swift
//  My Orders
//
//  Created by שיראל זכריה on 13/01/2024.
//

import Foundation
import CryptoKit

class Encryption {

    static func encryptID(userID: String) throws -> String {
        let key = SymmetricKey(size: .bits256)
        let data = Data(userID.utf8) //or
        //    let retailerID = "abc123".data(using: .utf8)!
        
        
        //    let encryptedData = try AES.GCM.seal(data, using: key).combined
        //    return encryptedData.base64EncodedString()
        
        let sealedBox = try AES.GCM.seal(data, using: key)
        let encryptedID = sealedBox.combined!.base64EncodedString()
        return encryptedID
        
    }
    
    static func decryptID(encryptedID: String) throws -> String {
        //    let encryptedData = try Data(base64Encoded: encryptedID)!
        //    let decryptedData = try AES.GCM.open(encryptedData!, using: secretKey)
        //    return String(data: decryptedData, encoding: .utf8)!
        
        let key = SymmetricKey(size: .bits256)
        
        let sealedBoxData = Data(base64Encoded: encryptedID)!
        let sealedBox = try AES.GCM.SealedBox(combined: sealedBoxData)
        
        // Decrypt using the stored key
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        let decryptedID = String(data: decryptedData, encoding: .utf8)!
        return decryptedID
    }
}

//usage:
//// Sender
//let userID = "uniqueUserID"
//let secretKey = SymmetricKey(size: .bits256) // Generate a secure secret key
//let encryptedID = try encryptID(userID: userID, secretKey: secretKey)
//
//// Receiver
//let decryptedID = try decryptID(encryptedID: encryptedID, secretKey: secretKey)
//print("Decrypted ID: \(decryptedID)")

