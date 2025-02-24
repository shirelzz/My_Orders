////
////  Coder.swift
////  My Orders
////
////  Created by שיראל זכריה on 25/01/2024.
////
//
//import Foundation
//import CommonCrypto
//
//class Coder {
//    private let encryptionKey = "yourEncryptionKey" // Replace with your actual encryption key
//    
//    // Encrypt user ID
//    func encryptUserID(userID: String) -> String? {
//        guard let keyData = encryptionKey.data(using: .utf8),
//              let inputData = userID.data(using: .utf8) else {
//            return nil
//        }
//        
//        var encryptedData = Data(count: inputData.count + kCCBlockSizeAES128)
//        
//        let status = encryptedData.withUnsafeMutableBytes { encryptedBytes in
//            inputData.withUnsafeBytes { inputBytes in
//                keyData.withUnsafeBytes { keyBytes in
//                    CCCrypt(
//                        UInt32(kCCEncrypt),
//                        UInt32(kCCAlgorithmAES),
//                        UInt32(kCCOptionPKCS7Padding),
//                        keyBytes.baseAddress,
//                        keyData.count,
//                        nil,
//                        inputBytes.baseAddress,
//                        inputData.count,
//                        encryptedBytes.baseAddress,
//                        encryptedData.count,
//                        encryptedBytes.baseAddress,
//                        &encryptedData.count
//                    )
//                }
//            }
//        }
//        
//        guard status == kCCSuccess else {
//            return nil
//        }
//        
//        return encryptedData.base64EncodedString()
//    }
//    
//    // Decrypt public code to get user details
//    func decryptPublicCode(publicCode: String) -> String? {
//        guard let keyData = encryptionKey.data(using: .utf8),
//              let encryptedData = Data(base64Encoded: publicCode) else {
//            return nil
//        }
//        
//        var decryptedData = Data(count: encryptedData.count + kCCBlockSizeAES128)
//        
//        let status = decryptedData.withUnsafeMutableBytes { decryptedBytes in
//            encryptedData.withUnsafeBytes { encryptedBytes in
//                keyData.withUnsafeBytes { keyBytes in
//                    CCCrypt(
//                        UInt32(kCCDecrypt),
//                        UInt32(kCCAlgorithmAES),
//                        UInt32(kCCOptionPKCS7Padding),
//                        keyBytes.baseAddress,
//                        keyData.count,
//                        nil,
//                        encryptedBytes.baseAddress,
//                        encryptedData.count,
//                        decryptedBytes.baseAddress,
//                        decryptedData.count,
//                        decryptedBytes.baseAddress,
//                        &decryptedData.count
//                    )
//                }
//            }
//        }
//        
//        guard status == kCCSuccess else {
//            return nil
//        }
//        
//        return String(data: decryptedData, encoding: .utf8)
//    }
//}
//
//// Example usage:
//let coder = Coder()
//
//// Encrypt user ID
//if let publicCode = coder.encryptUserID(userID: "123456") {
//    print("Public Code: \(publicCode)")
//    
//    // Decrypt public code to get user details
//    if let decryptedUserID = coder.decryptPublicCode(publicCode: publicCode) {
//        print("Decrypted User ID: \(decryptedUserID)")
//    } else {
//        print("Decryption failed.")
//    }
//} else {
//    print("Encryption failed.")
//}
