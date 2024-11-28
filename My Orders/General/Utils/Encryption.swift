//
//  Encryption.swift
//  My Orders
//
//  Created by שיראל זכריה on 13/01/2024.
//

import Foundation
import CryptoKit

class Encryption {
    
    private static var secretKey: SymmetricKey = SymmetricKey(size: .bits256)

    static func encryptID(userID: String) throws -> String {
        let data = Data(userID.utf8) //or
        let sealedBox = try AES.GCM.seal(data, using: secretKey)
        let encryptedID = sealedBox.combined!.base64EncodedString()
        return encryptedID
        
    }

    static func decryptID(encryptedID: String) throws -> String {
        do {
            let sealedBoxData = Data(base64Encoded: encryptedID)!
            let sealedBox = try AES.GCM.SealedBox(combined: sealedBoxData)

            // Decrypt using the stored key
            let decryptedData = try AES.GCM.open(sealedBox, using: secretKey)
            let decryptedID = String(data: decryptedData, encoding: .utf8)!

            print("--> decryptedID: \(decryptedID)")
            return decryptedID
        } catch {
            print("Error decrypting ID: \(error)")
            throw error
        }
    }
}
