//
//  ReceiptSettingsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 29/11/2023.
//

import SwiftUI

struct ReceiptSettingsView: View {
    
    @ObservedObject var appManager: AppManager
    @State private var receiptNumber = 0

    
    var body: some View {
        
        Form{
            
            Text("Start creatng receipts at")
            TextField("Receipt number", text: Binding<String>(
                get: { String(receiptNumber) },
                set: { if let newValue = Int($0) { receiptNumber = newValue} }
            ))
            .keyboardType(.numberPad)
        }
    }
}

//#Preview {
//    @ObservedObject var appManager: AppManager
//
//    ReceiptSettingsView(appManager: appManager)
//}
