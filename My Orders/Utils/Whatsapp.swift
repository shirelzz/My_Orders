//
//  Whatsapp.swift
//  My Orders
//
//  Created by שיראל זכריה on 02/12/2023.
//

import SwiftUI


struct WhatsAppChatButton: View {
    var phoneNumber: String

    var body: some View {
        Button(action: {
//            if let url = URL(string: "https://wa.me/\(phoneNumber)") { //(Int(phoneNumber) ?? 0)
//                UIApplication.shared.open(url)
//            }
            if let formattedNumber = formatPhoneNumber(phoneNumber) {
                            if let url = URL(string: "https://wa.me/\(formattedNumber)") {
                                UIApplication.shared.open(url)
                            }
                        }
        }) {
            HStack {
                Image(systemName: "message")
//                Text("WhatsApp")
            }
        }
    }
    private func formatPhoneNumber(_ number: String) -> String? {
            // Remove non-digit characters
            let digitOnlyPhoneNumber = number.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
            guard !digitOnlyPhoneNumber.isEmpty else { return nil }

            // Ensure international format
            var formattedNumber = digitOnlyPhoneNumber
            if formattedNumber.hasPrefix("05") {
                    // Israeli numbers starting with "05" - remove leading "0"
                formattedNumber = String(formattedNumber.dropFirst())
            } else if !formattedNumber.hasPrefix("+") {
                    // Add country code if not present
                formattedNumber = "+" + formattedNumber // Assuming USA's country code is +1
            }
//            if formattedNumber.hasPrefix("05") {
//                formattedNumber // Assuming Israel's country code is +972
//            }
//        
//            // Check if the phone number starts with a plus sign, if not, add it
//            if !formattedNumber.hasPrefix("+") {
//            formattedNumber = "+" + formattedNumber
//            }

            // URL encode the phone number
            if let encodedNumber = formattedNumber.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
                return encodedNumber
            }

            return nil
        }
    
          
}
