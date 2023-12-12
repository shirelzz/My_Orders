//
//  Whatsapp.swift
//  My Orders
//
//  Created by שיראל זכריה on 02/12/2023.
//

import SwiftUI


struct WhatsAppChatButton: View {
    var phoneNumber: Int

    var body: some View {
        Button(action: {
            if let url = URL(string: "https://wa.me/\(phoneNumber)") {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                Image(systemName: "message")
//                Text("WhatsApp")
            }
        }
    }
}
