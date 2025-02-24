//
//  AESCryptor.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/04/2024.
//

import Foundation
import CryptoSwift

class AESCryptor {
    
        private static let key = "2tC2H19gBjbQDfa90JrtNMQdd0FloLyw"
        private static let iv = "bmC2Hj4lkVbQDyuk"
    
    static func encrypt(_ text: String) throws -> String {
        let data = text.data(using: .utf8)!
        let encrypted = try AES(key: key, iv: iv, padding: .pkcs7).encrypt([UInt8](data))
        let encryptedData = Data(encrypted)
        return encryptedData.toHexString()
    }
    
    static func decrypt(_ encryptedText: String) throws -> String {
        let data = encryptedText.dataFromHexadecimalString()!
        let decrypted = try AES(key: key, iv: iv, padding:.pkcs7).decrypt([UInt8](data))
        let decryptedData = Data(decrypted)
        return String(bytes: decryptedData.bytes, encoding: .utf8) ?? "Could not decrypt"
    }
    
    static func dataFromHexadecimalString(_ hexString: String) -> Data? {
        var data = Data(capacity: hexString.count / 2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: hexString, options: [], range: NSMakeRange(0, hexString.count)) { match, _, _ in
            let byteString = (hexString as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)
            data.append(num!)
        }
        return data
    }
}

extension Data {
    var bytes: Array<UInt8> {
        return Array(self)
    }
    
    func toHexString() -> String {
        return bytes.toHexString()
    }
}

extension String {
    func dataFromHexadecimalString() -> Data? {
        return AESCryptor.dataFromHexadecimalString(self)
    }
}
